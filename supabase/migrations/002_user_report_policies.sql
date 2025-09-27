-- RLS Policies for Users Table
-- Admins can read all users, users can read their own profile
CREATE POLICY "Users: Admins can read all" ON public.users
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Users: Users can read own profile" ON public.users
    FOR SELECT USING (public.user_owns_resource(id));

CREATE POLICY "Users: Admins can update users" ON public.users
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Users: Users can update own profile" ON public.users
    FOR UPDATE USING (public.user_owns_resource(id));

CREATE POLICY "Users: Allow signup" ON public.users
    FOR INSERT WITH CHECK (true);

-- RLS Policies for Reports Table
-- Admins can access all reports, citizens can only access their own
CREATE POLICY "Reports: Admins can read all" ON public.reports
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Reports: Users can read own reports" ON public.reports
    FOR SELECT USING (public.user_owns_resource(user_id));

CREATE POLICY "Reports: Admins can update all" ON public.reports
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Reports: Allow report submission" ON public.reports
    FOR INSERT WITH CHECK (true);

-- RLS Policies for Report Media
CREATE POLICY "Report Media: Admins can read all" ON public.report_media
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Report Media: Users can read own report media" ON public.report_media
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.reports 
            WHERE reports.id = report_media.report_id 
            AND reports.user_id = auth.uid()
        )
    );

CREATE POLICY "Report Media: Allow upload for own reports" ON public.report_media
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.reports 
            WHERE reports.id = report_media.report_id 
            AND (reports.user_id = auth.uid() OR public.is_admin())
        )
    );

-- RLS Policies for Report Comments
CREATE POLICY "Report Comments: Admins can read all" ON public.report_comments
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Report Comments: Users can read public comments on own reports" ON public.report_comments
    FOR SELECT USING (
        NOT is_internal AND EXISTS (
            SELECT 1 FROM public.reports 
            WHERE reports.id = report_comments.report_id 
            AND reports.user_id = auth.uid()
        )
    );

CREATE POLICY "Report Comments: Admins can insert all" ON public.report_comments
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Report Comments: Users can insert public comments on own reports" ON public.report_comments
    FOR INSERT WITH CHECK (
        NOT is_internal AND EXISTS (
            SELECT 1 FROM public.reports 
            WHERE reports.id = report_comments.report_id 
            AND reports.user_id = auth.uid()
        )
    );

-- RLS Policies for Report Assignments
CREATE POLICY "Report Assignments: Admins only" ON public.report_assignments
    FOR ALL USING (public.is_admin());

-- RLS Policies for Report Status History
CREATE POLICY "Report Status History: Admins can read all" ON public.report_status_history
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Report Status History: Users can read own report history" ON public.report_status_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.reports 
            WHERE reports.id = report_status_history.report_id 
            AND reports.user_id = auth.uid()
        )
    );

CREATE POLICY "Report Status History: Admins can insert" ON public.report_status_history
    FOR INSERT WITH CHECK (public.is_admin());