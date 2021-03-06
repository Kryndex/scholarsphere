# frozen_string_literal: true

FactoryGirl.define do
  factory :work, aliases: [:private_file, :file, :private_work], class: GenericWork do
    transient do
      user { FactoryGirl.create(:user) }
      transfer_to nil
      file_title nil
      file_name nil
    end

    title ['Sample Title']
    after(:build) do |file, attrs|
      file.apply_depositor_metadata((attrs.depositor || 'user'))
      if file.admin_set.blank?
        initialize_default_adminset
        file.admin_set = AdminSet.first
      end
    end

    after(:create) do |file, attrs|
      file.request_transfer_to(attrs.transfer_to) if attrs.transfer_to
    end

    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

    factory :public_work, aliases: [:public_file] do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      factory :share_file do
        title ['SHARE Document']
        resource_type ['Dissertation']

        after(:build) do |work, evaluator|
          if evaluator.creators.blank?
            creator = create(:alias, display_name: 'Joe Contributor', agent: Agent.new(sur_name: 'Contributor', given_name: 'Joe'))
            work.creators = [creator]
          end
        end
      end

      factory :featured_file do
        after(:create) do |f|
          FeaturedWork.create!(work_id: f.id)
        end
      end

      factory :trophy_file do
        after(:create) do |f, attrs|
          Trophy.create!(user_id: User.find_by_login(attrs.depositor).id, work_id: f.id)
        end
      end
    end

    factory :registered_file, aliases: [:registered_work] do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end

    factory :public_work_without_filesets do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    factory :public_work_with_png do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      after(:create) do |work, attributes|
        fs = FactoryGirl.create(:file_set,
                                user: User.find_by_login(work.depositor),
                                title: ['A contained PNG file'],
                                label: 'world.png',
                                visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)

        file_path = "#{Rails.root}/spec/fixtures/world.png"
        IngestFileJob.perform_now(fs, file_path, attributes.user)

        work.ordered_members << fs
        work.thumbnail_id = fs.id
        work.representative_id = fs.id
        work.update_index
      end
    end

    # Does not call IngestFileJob directly. Because this is a mp3, ffmpeg is required for derivatives.
    # Travis does not have ffmpeg, so only add the file to the fileset and do not run characterization
    # or create any derivatives.
    factory :public_work_with_mp3 do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      after(:create) do |work, attributes|
        fs = FactoryGirl.create(:file_set,
                                user: attributes.user,
                                title: ['A contained MP3 file'],
                                label: 'scholarsphere_test5.mp3',
                                visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)

        filename = "#{Rails.root}/spec/fixtures/scholarsphere/scholarsphere_test5.mp3"
        local_file = File.open(filename, 'rb')
        Hydra::Works::AddFileToFileSet.call(fs, local_file, :original_file, versioning: false)
        fs.save!
        work.ordered_members << fs
        work.thumbnail_id = fs.id
      end
    end

    trait :with_one_file do
      before(:create) do |work, evaluator|
        fs = FactoryGirl.create(:file_set,
                                user: evaluator.user,
                                title: (evaluator.file_title || ['A Contained File']),
                                label: (evaluator.file_name || 'filename.pdf'))
        work.ordered_members << fs
        work.thumbnail_id = fs.id
      end
    end

    trait :with_one_file_and_size do
      before(:create) do |work, evaluator|
        fs = FactoryGirl.create(:file_set, :with_file_size,
                                user: evaluator.user,
                                title: (evaluator.file_title || ['A Contained File']),
                                label: (evaluator.file_name || 'filename.pdf'))
        work.ordered_members << fs
        work.thumbnail_id = fs.id
      end
    end

    trait :with_full_text_content do
      after(:build) do |f|
        f.full_text.content = 'full_textfull_text'
      end
    end

    trait :with_png do
      after(:build) do |f|
        f.add_file(File.open("#{Rails.root}/spec/fixtures/world.png", 'rb'), path: 'content')
      end
    end

    trait :with_pdf do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryGirl.create(:file_set, :pdf, user: evaluator.user)
      end
    end

    trait :characterized do
      after(:create, &:characterize)
    end

    trait :with_public_embargo do
      after(:build) do |work, evaluator|
        work.embargo = FactoryGirl.create(:public_embargo, embargo_release_date: evaluator.embargo_release_date)
      end
    end

    trait :with_public_lease do
      lease { FactoryGirl.create(:public_lease, lease_expiration_date: (Time.zone.today + 14.days)) }
    end

    trait :with_complete_metadata do
      title         ['titletitle']
      keyword       ['tagtag']
      based_near    ['based_nearbased_near']
      language      ['languagelanguage']
      contributor   ['contributorcontributor']
      publisher     ['publisherpublisher']
      subject       ['subjectsubject']
      resource_type ['resource_typeresource_type']
      description   ['descriptiondescription']
      related_url   ['http://example.org/TheRelatedURLLink/']
      rights        ['http://creativecommons.org/licenses/by/3.0/us/']
      date_created  ['two days after the day before yesterday']

      after(:build) do |work, evaluator|
        if evaluator.creators.blank?
          creator = create(:alias, display_name: 'creatorcreator', agent: Agent.new(given_name: 'Creator C.', sur_name: 'Creator'))
          work.creators = [creator]
        end
      end
    end

    trait :with_required_metadata do
      title         ['a required title']
      description   ['a required description']
      keyword       ['required keyword']
      rights        ['https://creativecommons.org/licenses/by/4.0/']
      resource_type ['Article']

      after(:build) do |work, evaluator|
        if evaluator.creators.blank?
          creator = create(:alias, display_name: 'required creator', agent: Agent.new(given_name: 'Required T.', sur_name: 'Creator'))
          work.creators = [creator]
        end
      end
    end
  end
end
