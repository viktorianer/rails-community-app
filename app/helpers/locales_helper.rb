module LocalesHelper
  # Remembers the user locale.
  def remember(locale)
    current_user.update_attribute(:locale, locale) if logged_in?
    session[:locale] = locale
    I18n.locale = locale
  end
end