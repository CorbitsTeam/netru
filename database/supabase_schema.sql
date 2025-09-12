-- Supabase Database Schema for Netru App Authentication

-- Create users table (general user table)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    profile_image TEXT,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('egyptian', 'foreigner')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create citizens table (Egyptian citizens)
CREATE TABLE IF NOT EXISTS public.citizens (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    profile_image TEXT,
    national_id VARCHAR(14) NOT NULL UNIQUE,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT check_national_id_format CHECK (national_id ~ '^\d{14}$'),
    CONSTRAINT check_phone_format CHECK (phone ~ '^01[0125]\d{8}$')
);

-- Create foreigners table (Foreign residents)
CREATE TABLE IF NOT EXISTS public.foreigners (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    profile_image TEXT,
    passport_number VARCHAR(50) NOT NULL,
    nationality VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.citizens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foreigners ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for users table
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for citizens table
CREATE POLICY "Citizens can view own profile" ON public.citizens
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Citizens can update own profile" ON public.citizens
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Citizens can insert own profile" ON public.citizens
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for foreigners table
CREATE POLICY "Foreigners can view own profile" ON public.foreigners
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Foreigners can update own profile" ON public.foreigners
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Foreigners can insert own profile" ON public.foreigners
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_user_type ON public.users(user_type);
CREATE INDEX idx_citizens_national_id ON public.citizens(national_id);
CREATE INDEX idx_citizens_email ON public.citizens(email);
CREATE INDEX idx_foreigners_passport ON public.foreigners(passport_number);
CREATE INDEX idx_foreigners_email ON public.foreigners(email);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_citizens_updated_at 
    BEFORE UPDATE ON public.citizens 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foreigners_updated_at 
    BEFORE UPDATE ON public.foreigners 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle user deletion
CREATE OR REPLACE FUNCTION handle_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete from users table
    DELETE FROM public.users WHERE id = OLD.id;
    -- Delete from citizens table if exists
    DELETE FROM public.citizens WHERE id = OLD.id;
    -- Delete from foreigners table if exists
    DELETE FROM public.foreigners WHERE id = OLD.id;
    RETURN OLD;
END;
$$ language 'plpgsql';

-- Create trigger for user deletion
CREATE TRIGGER on_auth_user_deleted
    AFTER DELETE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_user_deletion();

-- Create function to check user type consistency
CREATE OR REPLACE FUNCTION check_user_type_consistency()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if user exists in users table with correct type
    IF TG_TABLE_NAME = 'citizens' THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = NEW.id AND user_type = 'egyptian'
        ) THEN
            RAISE EXCEPTION 'User must be registered as Egyptian in users table first';
        END IF;
    ELSIF TG_TABLE_NAME = 'foreigners' THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = NEW.id AND user_type = 'foreigner'
        ) THEN
            RAISE EXCEPTION 'User must be registered as foreigner in users table first';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for type consistency
CREATE TRIGGER check_citizen_type_consistency
    BEFORE INSERT OR UPDATE ON public.citizens
    FOR EACH ROW EXECUTE FUNCTION check_user_type_consistency();

CREATE TRIGGER check_foreigner_type_consistency
    BEFORE INSERT OR UPDATE ON public.foreigners
    FOR EACH ROW EXECUTE FUNCTION check_user_type_consistency();
