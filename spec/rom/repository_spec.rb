require 'spec_helper'
require 'fileutils'
require 'json'

describe 'ROM Repository Attaching using Shrine ROM' do
  after do
    FileUtils.rm_rf('spec/tmp/uploads')
  end

  let(:image) { ::File.open('spec/support/images/cat.jpg') }
  let(:image2) { ::File.open('spec/support/images/cat2.jpg') }

  let(:kitten_repository) { Repositories::KittenRepository.new }
  let(:multi_cat_repository) { Repositories::MultiCatRepository.new }

  let(:multi_cat_entity) { Entities::MultiCat.new }
  let(:kitten_entity) { Entities::Kitten.new }

  let(:cat) do
    attacher = kitten_entity.image_attacher
    attacher.assign(image)
    attacher.finalize
  
    kitten_repository.create(image_data: attacher.column_data)
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
        cat1_attacher = multi_cat_entity.cat1_attacher
        cat1_attacher.assign(image)
        cat1_attacher.finalize
        
        cat = multi_cat_repository.create(cat1_data: cat1_attacher.column_data)

        expect(cat.cat1).not_to be_nil
        expect(cat.cat2).to be_nil
        json_data = JSON.parse(cat.cat1_data)
        expect(File.exist?('spec/tmp/uploads/' + json_data["id"])).to eq(true)
      end

      it 'saves both' do
        cat1_attacher = multi_cat_entity.cat1_attacher
        cat1_attacher.assign(image)
        cat1_attacher.finalize

        cat2_attacher = multi_cat_entity.cat2_attacher
        cat2_attacher.assign(image2)
        cat2_attacher.finalize

        cat = multi_cat_repository.create(cat1_data: cat2_attacher.column_data, cat2_data: cat2_attacher.column_data)

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
      attacher = kitten_entity.image_attacher
      attacher.assign(File.open('spec/support/images/cat2.jpg'))
      attacher.finalize

      kitten_repository.update(cat.id, image_data: attacher.column_data)
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
        attacher = kitten_entity.image_attacher
        attacher.assign(image)
        attacher.finalize
        
        kitten_repository.create(image_data: attacher.column_data)
      end

      include_context 'creation'
    end
  end

  context '#delete', skip: true do
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
        attacher = kitten_entity.image_attacher
        attacher.assign(image)
        attacher.finalize
        
        kitten_repository.create(image_data: attacher.column_data)
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
