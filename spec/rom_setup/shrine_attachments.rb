require 'image_processing/mini_magick'

class ImageAttachment < Shrine
  plugin :rom
end

class ComplexAttachment < Shrine
  include ImageProcessing::MiniMagick
  plugin :rom
  plugin :processing
  plugin :versions   # enable Shrine to handle a hash of files
  plugin :delete_raw # delete processed files after uploading
  plugin :determine_mime_type
  plugin :store_dimensions

  process(:store) do |io, context|
    io.download do |original|
      size_100 = ImageProcessing::MiniMagick.source(original).resize_to_limit!(100, 100)
      size_30 = ImageProcessing::MiniMagick.source(original).resize_to_limit!(30, 30)

      {original: io, small: size_100, tiny: size_30}
    end
  end
end