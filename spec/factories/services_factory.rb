FactoryGirl.define do
  factory :service do
    sequence(:natural_key) { |n| '%04d' % n }
    name 'Renew Service'

    delivery_organisation
  end
end
