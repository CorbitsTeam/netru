-- Identity Documents Verification Schema for Netru App
-- This schema extends the existing users table with identity verification functionality

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Update users table to include verification status
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS verification_status VARCHAR(20) DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'pending', 'verified', 'rejected')),
ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP WITH TIME ZONE;

-- Create identity_documents table
CREATE TABLE IF NOT EXISTS identity_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(20) NOT NULL CHECK (document_type IN ('national_id', 'passport')),
    document_number VARCHAR(50) NOT NULL,
    full_name TEXT NOT NULL,
    date_of_birth VARCHAR(20) NOT NULL,
    nationality VARCHAR(50),
    expiry_date VARCHAR(20),
    issue_date VARCHAR(20),
    place_of_birth VARCHAR(100),
    image_url TEXT NOT NULL,
    extracted_data_json JSONB,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_identity_documents_user_id ON identity_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_identity_documents_status ON identity_documents(status);
CREATE INDEX IF NOT EXISTS idx_identity_documents_document_type ON identity_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_identity_documents_created_at ON identity_documents(created_at);

-- Create verification_logs table for audit trail
CREATE TABLE IF NOT EXISTS verification_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES identity_documents(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL, -- 'submitted', 'approved', 'rejected', 'resubmitted'
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    reason TEXT,
    performed_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verification_logs_document_id ON verification_logs(document_id);
CREATE INDEX IF NOT EXISTS idx_verification_logs_user_id ON verification_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_logs_created_at ON verification_logs(created_at);

-- Create storage bucket for identity documents
INSERT INTO storage.buckets (id, name, public) 
VALUES ('identity_docs', 'identity_docs', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for identity documents
CREATE POLICY "Users can upload their own identity documents" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'identity_docs' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view their own identity documents" ON storage.objects
FOR SELECT USING (
    bucket_id = 'identity_docs' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Admins can view all identity documents" ON storage.objects
FOR SELECT USING (
    bucket_id = 'identity_docs' 
    AND EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND (email LIKE '%@admin.netru.gov.eg' OR role = 'admin')
    )
);

-- Row Level Security policies for identity_documents table
ALTER TABLE identity_documents ENABLE ROW LEVEL SECURITY;

-- Users can insert their own documents
CREATE POLICY "Users can insert their own identity documents" ON identity_documents
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can view their own documents
CREATE POLICY "Users can view their own identity documents" ON identity_documents
FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own pending documents
CREATE POLICY "Users can update their own pending documents" ON identity_documents
FOR UPDATE USING (
    auth.uid() = user_id 
    AND status = 'pending'
) WITH CHECK (
    auth.uid() = user_id 
    AND status = 'pending'
);

-- Admins can view all documents
CREATE POLICY "Admins can view all identity documents" ON identity_documents
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND (email LIKE '%@admin.netru.gov.eg' OR role = 'admin')
    )
);

-- Admins can update document status
CREATE POLICY "Admins can update document status" ON identity_documents
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND (email LIKE '%@admin.netru.gov.eg' OR role = 'admin')
    )
) WITH CHECK (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND (email LIKE '%@admin.netru.gov.eg' OR role = 'admin')
    )
);

-- Row Level Security policies for verification_logs table
ALTER TABLE verification_logs ENABLE ROW LEVEL SECURITY;

-- Users can view their own verification logs
CREATE POLICY "Users can view their own verification logs" ON verification_logs
FOR SELECT USING (auth.uid() = user_id);

-- System can insert verification logs
CREATE POLICY "System can insert verification logs" ON verification_logs
FOR INSERT WITH CHECK (true);

-- Admins can view all verification logs
CREATE POLICY "Admins can view all verification logs" ON verification_logs
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND (email LIKE '%@admin.netru.gov.eg' OR role = 'admin')
    )
);

-- Function to automatically log verification status changes
CREATE OR REPLACE FUNCTION log_verification_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Log the status change
    INSERT INTO verification_logs (
        document_id,
        user_id,
        action,
        old_status,
        new_status,
        reason,
        performed_by
    ) VALUES (
        NEW.id,
        NEW.user_id,
        CASE 
            WHEN OLD.status IS NULL THEN 'submitted'
            WHEN OLD.status = 'pending' AND NEW.status = 'verified' THEN 'approved'
            WHEN OLD.status = 'pending' AND NEW.status = 'rejected' THEN 'rejected'
            WHEN OLD.status IN ('rejected', 'verified') AND NEW.status = 'pending' THEN 'resubmitted'
            ELSE 'updated'
        END,
        OLD.status,
        NEW.status,
        NEW.rejection_reason,
        auth.uid()
    );
    
    -- Update user verification status if document is verified
    IF NEW.status = 'verified' AND (OLD.status IS NULL OR OLD.status != 'verified') THEN
        UPDATE users 
        SET verification_status = 'verified', verified_at = NOW()
        WHERE id = NEW.user_id;
    ELSIF NEW.status = 'pending' AND OLD.status = 'rejected' THEN
        UPDATE users 
        SET verification_status = 'pending', verified_at = NULL
        WHERE id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic logging
DROP TRIGGER IF EXISTS trigger_log_verification_status_change ON identity_documents;
CREATE TRIGGER trigger_log_verification_status_change
    AFTER INSERT OR UPDATE ON identity_documents
    FOR EACH ROW EXECUTE FUNCTION log_verification_status_change();

-- Function to check if user has verified identity
CREATE OR REPLACE FUNCTION user_has_verified_identity(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM identity_documents 
        WHERE user_id = user_uuid AND status = 'verified'
    );
END;
$$ LANGUAGE plpgsql;

-- Function to get user verification status
CREATE OR REPLACE FUNCTION get_user_verification_status(user_uuid UUID)
RETURNS TABLE (
    has_documents BOOLEAN,
    has_pending BOOLEAN,
    has_verified BOOLEAN,
    latest_status VARCHAR,
    latest_document_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        EXISTS(SELECT 1 FROM identity_documents WHERE user_id = user_uuid) as has_documents,
        EXISTS(SELECT 1 FROM identity_documents WHERE user_id = user_uuid AND status = 'pending') as has_pending,
        EXISTS(SELECT 1 FROM identity_documents WHERE user_id = user_uuid AND status = 'verified') as has_verified,
        (SELECT status FROM identity_documents WHERE user_id = user_uuid ORDER BY created_at DESC LIMIT 1) as latest_status,
        (SELECT id FROM identity_documents WHERE user_id = user_uuid ORDER BY created_at DESC LIMIT 1) as latest_document_id;
END;
$$ LANGUAGE plpgsql;

-- Create view for admin dashboard
CREATE OR REPLACE VIEW verification_dashboard AS
SELECT 
    id.id,
    id.user_id,
    u.email,
    u.full_name as user_name,
    id.full_name as document_name,
    id.document_type,
    id.document_number,
    id.status,
    id.created_at,
    id.verified_at,
    id.rejection_reason,
    EXTRACT(EPOCH FROM (NOW() - id.created_at))/3600 as hours_since_submission
FROM identity_documents id
JOIN users u ON id.user_id = u.id
ORDER BY id.created_at DESC;

-- Grant permissions
GRANT SELECT ON verification_dashboard TO authenticated;

-- Sample data for testing (optional)
-- Note: This would only be used in development/testing environments

-- Insert sample admin user (only for development)
-- INSERT INTO users (id, email, full_name, user_type, role) 
-- VALUES (uuid_generate_v4(), 'admin@netru.gov.eg', 'مدير النظام', 'egyptian', 'admin')
-- ON CONFLICT (email) DO NOTHING;

-- Comments for documentation
COMMENT ON TABLE identity_documents IS 'Stores identity documents uploaded by users for verification';
COMMENT ON TABLE verification_logs IS 'Audit trail for all verification status changes';
COMMENT ON FUNCTION user_has_verified_identity IS 'Check if a user has at least one verified identity document';
COMMENT ON FUNCTION get_user_verification_status IS 'Get comprehensive verification status for a user';
COMMENT ON VIEW verification_dashboard IS 'Admin dashboard view for managing identity verifications';
