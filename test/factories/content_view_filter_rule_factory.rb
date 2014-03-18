FactoryGirl.define do
  factory :katello_content_view_package_filter_rule,
          :class => Katello::ContentViewPackageFilterRule do
    sequence(:name) { |n| "package #{n}"}
  end

  factory :katello_content_view_package_group_filter_rule,
          :class => Katello::ContentViewPackageGroupFilterRule do
    sequence(:name) { |n| "package group #{n}"}
  end

  factory :katello_content_view_erratum_filter_rule,
          :class => Katello::ContentViewErratumFilterRule do
    sequence(:errata_id) { |n| "RHBA-2014-#{n}"}
    association :filter, :factory => :katello_content_view_erratum_filter
  end
end
