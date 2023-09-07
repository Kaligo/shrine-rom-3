require 'spec_helper'
require 'fileutils'
require 'json'

describe 'Hanami::Shrine::Repository' do
  after do
    FileUtils.rm_rf('spec/tmp/uploads')
  end

  let(:image) { ::File.open('spec/support/images/cat.jpg') }
  let(:image2) { ::File.open('spec/support/images/cat2.jpg') }

  let(:kitten_repository) { Repositories::KittenRepository.new }
  let(:multi_cat_repository) { Repositories::MultiCatRepository.new }

  let(:kitten_entity) { kitten_repository.root.select(:image).mapper.model }

  let(:cat) do
    cat = kitten_entity.new(image: image)
    kitten_repository.create(cat)
  end

  shared_context 'creation' do

    it 'should not be in temp dir' do
      expect(cat.image_url).not_to match(/^#{Dir.tmpdir}/)
    end

    it 'exist? should be true' do
      expect(cat.image.exists?).to eq(true)
    end

    it 'should really exist' do
      json_data = JSON.parse(cat.image_data)
      expect(File.exist?('spec/tmp/uploads/' + json_data["id"])).to eq(true)
    end

    context 'with mutliple attachments' do
      it 'saves one of them' do
        cat = multi_cat_repository.root.select(:cat1).mapper.model.new(cat1: image)
        cat = multi_cat_repository.create(cat)
        expect(cat.cat1).not_to be_nil
        expect(cat.cat2).to be_nil
        json_data = JSON.parse(cat.cat1_data)
        expect(File.exist?('spec/tmp/uploads/' + json_data["id"])).to eq(true)
      end

      it 'saves both' do
        cat = multi_cat_repository.root.select(:cat1, :cat2).mapper.model.new(cat1: image, cat2: image2)
        cat = multi_cat_repository.create(cat)
        expect(cat.cat2).not_to be_nil
        expect(cat.cat1).not_to be_nil
        json_data = JSON.parse(cat.cat1_data)
        expect(File.exist?('spec/tmp/uploads/' + json_data["id"])).to eq(true)
        json_data = JSON.parse(cat.cat2_data)
        expect(File.exist?('spec/tmp/uploads/' + json_data["id"])).to eq(true)
      end
   end
  end

  shared_context 'update' do
    let!(:before_update_data) { JSON.parse(cat.image_data) }
    let(:new_data) { JSON.parse(updated_cat.image_data) }
    let(:updated_cat) do
      new_cat = kitten_entity.new(image: File.open('spec/support/images/cat2.jpg'))
      kitten_repository.update(cat.id, new_cat)
    end

    it 'should have different id' do
      expect(new_data['id']).not_to eq(before_update_data['id'])
    end

    it 'should have different url' do
      old_url = cat.image_url
      expect(updated_cat.image_url).not_to eq(old_url)
    end

    it 'should not be in temp dir' do
      expect(updated_cat.image_url).not_to match(/^#{Dir.tmpdir}/)
    end
  end

  # --- SPECS BEGIN HERE --- #

  context '#create' do
    include_context 'creation'

    context 'with hash params' do
      let(:cat) do
        kitten_repository.create(image: image)
      end

      include_context 'creation'
    end
  end

  context '#delete' do
    let!(:before_delete_data) { JSON.parse(cat.image_data) }

    before do
      kitten_repository.delete(cat.id)
    end

    it 'should not exist' do
      expect(File.exist?('spec/tmp/uploads/' + before_delete_data["id"])).not_to eq(true)
    end

    it 'should delete entity' do
      expect(cat.id).not_to be_nil
      expect(kitten_repository.find(cat.id)).to eq(nil)
    end
  end

  context '#update' do
    include_context 'update'

    context 'with hash params' do
      let(:cat) do
        kitten_repository.create(image: image)
      end

      include_context 'update'
    end
  end

  context '#persist' do
    context 'on create' do
      include_context 'creation'
    end

    context 'on update' do
      include_context 'update'
    end
  end
end
