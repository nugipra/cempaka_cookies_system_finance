module ApplicationHelper

  def member_label(member)
    return member.app_marketer? ? "App Marketer" : "Member"
  end
end
