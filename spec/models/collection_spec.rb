# frozen_string_literal: true

require 'rails_helper'

describe Collection do
  subject { collection }

  describe '#creators=' do
    let(:collection) do
      Collection.new(title: ['A Collection']) do |coll|
        coll.apply_depositor_metadata('hello@example.com')
      end
    end

    context 'with attributes' do
      let(:attrs) do
        {
          "0" => { "first_name"=>"Joe", "last_name"=>"Smith" },
          "1" => { "first_name"=>"Yuki", "last_name"=>"Maeda" }
        }
      end

  # 999 START HERE ??
      it 'creates the Person records' do
        expect{ collection.creators=(attrs) }.to change { Person.count }.by(2)
        collection.save!
        expect(collection.creators.map(&:first_name)).to contain_exactly('Joe', 'Yuki')
        expect(collection.creators.map(&:last_name)).to contain_exactly('Smith', 'Maeda')
      end
    end
  end

  context 'with no attached files' do
    let(:collection) { build(:collection) }

    its(:bytes) { is_expected.to eq(0) }
  end

  context 'with attached files' do
    let!(:collection) { create(:public_collection, members: [work1, work2]) }

    let(:work1)       { build(:public_work, id: '1') }
    let(:work2)       { build(:public_work, id: '2') }
    let(:resp) do
      [{ Solrizer.solr_name(:file_size, CurationConcerns::CollectionIndexer::STORED_LONG) => '20' }]
    end

    before { allow(ActiveFedora::SolrService).to receive(:query).and_return(resp) }
    its(:bytes) { is_expected.to eq(40) }
  end

  describe '::indexer' do
    let(:collection) { described_class }

    its(:indexer) { is_expected.to eq(CollectionIndexer) }
  end

  context 'with a new collection' do
    let(:collection) { build(:collection) }

    it { is_expected.not_to be_private_access }
    it { is_expected.to be_open_access }
  end
end
