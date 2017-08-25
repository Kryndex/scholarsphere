# frozen_string_literal: true

require 'rails_helper'

describe CurationConcerns::Actors::GenericWorkActor do
  let(:user) { create(:user) }
  let(:work) { build(:work, user: user) }

  let(:actor_stack) { CurationConcerns::Actors::ActorStack.new(work, user, [described_class]) }

  before do
    actor_stack.create(attributes)

    # saving work to be certain we are looking at the work in the repository
    work.save
    work.reload
  end

  context 'with ordered attributes' do
    let(:attributes) do
      {
        creators: { "0" => { "first_name" => "a",
                             "last_name"=>"A" },
                    "1" => { "first_name" => "b",
                             "last_name"=>"B" },
                    "2" => { "first_name" => "c",
                             "last_name"=>"C" },
                    "3" => { "first_name" => "d",
                             "last_name"=>"D" } },
        title: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
      }
    end

    # TODO: The magic that made the ordering work for Strings doesn't seem to work for URIs.
    it 'keeps the correct order' do
      expect(work.creators.map(&:first_name)).to eq(['a', 'b', 'c', 'd'])
      expect(work.creators.map(&:last_name)).to eq(['A', 'B', 'C', 'D'])
      expect(work.title).to eq(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'])
    end
  end

  context 'creator nil' do
    let(:attributes) { { creators: nil } }

    it 'does not error' do
      expect(work.creators).to eq([])
    end
  end

  context 'with an existing Person record' do
    let!(:existing_person) { create(:person) }
    let(:attributes) do
      { creators: {
        '0' => { id: existing_person.id, first_name: 'a' }
      } }
    end

    it 'sets creator to existing Person record' do
      expect(work.creators).to eq [existing_person]
    end
  end

  context 'creator id nil' do
    let(:attributes) do
      { creators: {
        '0' => { id: nil, first_name: 'first', last_name: 'last' }
      } }
    end

    it 'does not error' do
      expect(work.creators.map(&:first_name)).to eq ['first']
      expect(work.creators.map(&:last_name)).to eq ['last']
    end
  end

  context 'when uploading on behalf of another user' do
    subject { work }

    let(:other_user) { create(:user) }
    let(:attributes) { { title: ['Sample'], on_behalf_of: other_user.login } }

    its(:depositor) { is_expected.to eq(other_user.login) }
  end
end
