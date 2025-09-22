-- RLS Policies for Identity Documents
CREATE POLICY "Identity Documents: Admins can read all" ON public.identity_documents
    FOR SELECT USING (auth.is_admin());

CREATE POLICY "Identity Documents: Users can read own documents" ON public.identity_documents
    FOR SELECT USING (auth.user_owns_resource(user_id));

CREATE POLICY "Identity Documents: Users can upload own documents" ON public.identity_documents
    FOR INSERT WITH CHECK (auth.user_owns_resource(user_id));

CREATE POLICY "Identity Documents: Admins can update verification status" ON public.identity_documents
    FOR UPDATE USING (auth.is_admin());

-- RLS Policies for Notifications
CREATE POLICY "Notifications: Admins can read all" ON public.notifications
    FOR SELECT USING (auth.is_admin());

CREATE POLICY "Notifications: Users can read own notifications" ON public.notifications
    FOR SELECT USING (auth.user_owns_resource(user_id));

CREATE POLICY "Notifications: Admins can create notifications" ON public.notifications
    FOR INSERT WITH CHECK (auth.is_admin());

CREATE POLICY "Notifications: Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.user_owns_resource(user_id));

-- RLS Policies for FCM Tokens
CREATE POLICY "FCM Tokens: Admins can read all" ON public.user_fcm_tokens
    FOR SELECT USING (auth.is_admin());

CREATE POLICY "FCM Tokens: Users can manage own tokens" ON public.user_fcm_tokens
    FOR ALL USING (auth.user_owns_resource(user_id));

-- RLS Policies for User Logs (Admin read-only)
CREATE POLICY "User Logs: Admins can read all" ON public.user_logs
    FOR SELECT USING (auth.is_admin());

CREATE POLICY "User Logs: System can insert" ON public.user_logs
    FOR INSERT WITH CHECK (true);

-- RLS Policies for News Articles
CREATE POLICY "News Articles: Anyone can read published" ON public.news_articles
    FOR SELECT USING (is_published = true OR auth.is_admin());

CREATE POLICY "News Articles: Admins can manage all" ON public.news_articles
    FOR ALL USING (auth.is_admin());

-- RLS Policies for News Categories
CREATE POLICY "News Categories: Anyone can read active" ON public.news_categories
    FOR SELECT USING (is_active = true OR auth.is_admin());

CREATE POLICY "News Categories: Admins can manage all" ON public.news_categories
    FOR ALL USING (auth.is_admin());

-- RLS Policies for Report Types
CREATE POLICY "Report Types: Anyone can read active" ON public.report_types
    FOR SELECT USING (is_active = true OR auth.is_admin());

CREATE POLICY "Report Types: Admins can manage all" ON public.report_types
    FOR ALL USING (auth.is_admin());

-- RLS Policies for Governorates and Cities (Read-only for all)
CREATE POLICY "Governorates: Anyone can read" ON public.governorates
    FOR SELECT USING (true);

CREATE POLICY "Cities: Anyone can read" ON public.cities
    FOR SELECT USING (true);

CREATE POLICY "Governorates: Admins can manage" ON public.governorates
    FOR ALL USING (auth.is_admin());

CREATE POLICY "Cities: Admins can manage" ON public.cities
    FOR ALL USING (auth.is_admin());

-- RLS Policies for Profiles
CREATE POLICY "Profiles: Users can read own profile" ON public.profiles
    FOR SELECT USING (auth.user_owns_resource(id));

CREATE POLICY "Profiles: Admins can read all profiles" ON public.profiles
    FOR SELECT USING (auth.is_admin());

CREATE POLICY "Profiles: Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.user_owns_resource(id));

CREATE POLICY "Profiles: Allow profile creation" ON public.profiles
    FOR INSERT WITH CHECK (auth.user_owns_resource(id));