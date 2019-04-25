require 'katello_test_helper'

module ::Actions::Pulp3
  class FileUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:generic_file)
      @repo.root.update_attributes(:url => 'http://test/test/')
      create_repo(@repo, @master)

      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo,
        repository_creation: true)

      @repo.root.update_attributes(
        verify_ssl_on_sync: false,
        ssl_ca_cert: katello_gpg_keys(:unassigned_gpg_key),
        ssl_client_cert: katello_gpg_keys(:unassigned_gpg_key),
        ssl_client_key: katello_gpg_keys(:unassigned_gpg_key))
    end

    def test_update_ssl_validation
      skip "TODO: blocked by https://pulp.plan.io/issues/4506"

      assert @repo.root.verify_ssl_on_sync, "Respository verify_ssl_on_sync option was false."
      @repo.root.update_attributes(
        verify_ssl_on_sync: false)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @master)
    end

    def test_update_unprotected
      assert @repo.root.unprotected
      assert_equal 2, Katello::Pulp3::DistributionReference.where(
        root_repository_id: @repo.root.id).count

      @repo.root.update_attributes(unprotected: false)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @master)

      dist_refs = Katello::Pulp3::DistributionReference.where(
          root_repository_id: @repo.root.id)

      assert_equal 1, dist_refs.count

      assert dist_refs.first.path.start_with?('https')
    end
  end
end
