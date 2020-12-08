require 'katello_test_helper'

module Katello
  class SubscriptionStatusTest < ActiveSupport::TestCase
    let(:host) do
      FactoryBot.build(:host, :with_subscription, :organization => get_organization)
    end

    let(:status) { host.get_status(Katello::SubscriptionStatus) }

    def setup
      ::Organization.any_instance.stubs(:simple_content_access?).returns(false)
    end

    def stub_status(status)
      Katello::Candlepin::Consumer.any_instance.stubs(:entitlement_status).returns(status)
    end

    def test_get_status
      assert host.get_status(Katello::SubscriptionStatus)
    end

    def test_to_status_valid
      stub_status(Katello::Candlepin::Consumer::ENTITLEMENTS_VALID)
      assert_equal Katello::SubscriptionStatus::VALID, status.to_status
    end

    def test_to_status_disabled
      stub_status(Katello::Candlepin::Consumer::ENTITLEMENTS_DISABLED)
      assert_equal Katello::SubscriptionStatus::DISABLED, status.to_status
    end

    def test_to_status_partial
      stub_status(Katello::Candlepin::Consumer::ENTITLEMENTS_PARTIAL)
      assert_equal Katello::SubscriptionStatus::PARTIAL, status.to_status
    end

    def test_to_status_invalid
      stub_status(Katello::Candlepin::Consumer::ENTITLEMENTS_INVALID)
      assert_equal Katello::SubscriptionStatus::INVALID, status.to_status
    end

    def test_to_status_unsubscribed_hypervisor
      host.subscription_facet.stubs(:unsubscribed_hypervisor?).returns(true)
      assert_equal Katello::SubscriptionStatus::UNSUBSCRIBED_HYPERVISOR, status.to_status
    end

    def test_sca_enabled
      ::Organization.any_instance.stubs(:simple_content_access?).returns(true)
      assert_equal Katello::SubscriptionStatus::DISABLED, status.to_status
    end

    def test_no_subscription_facet
      assert_equal Katello::SubscriptionStatus::UNKNOWN, FactoryBot.build(:host).get_status(Katello::SubscriptionStatus).to_status
    end

    def test_to_global
      stub_status(Katello::Candlepin::Consumer::ENTITLEMENTS_PARTIAL)
      status.status = Katello::SubscriptionStatus::PARTIAL
      assert_equal HostStatus::Global::WARN, status.to_global
    end

    def test_update
      host.save!
      stub_status(Katello::Candlepin::Consumer::ENTITLEMENTS_VALID)
      assert status.refresh!
    end
  end
end
