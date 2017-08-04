module Fae
  class AssetCloner
    NoFileForOriginalResource  = Class.new(StandardError)
    UnknownStorage             = Class.new(StandardError)

    attr_reader :original_resource, :resource, :mount_point

    def initialize(original_resource, resource, mount_point)
      @mount_point       = mount_point.to_sym
      @original_resource = original_resource
      @resource          = resource
    end

    def set_file
      if have_file?
        case original_resource_mounter.send(:storage).class.name
        when 'CarrierWave::Storage::File'
          set_file_for_local_storage
        when 'CarrierWave::Storage::Fog', 'CarrierWave::Storage::AWS'
          set_file_for_remote_storage
        else
          raise UnknownStorage
        end
      else
        raise NoFileForOriginalResource
      end
    end

    def have_file?
      original_resource_mounter.file.present? || original_resource_mounter.url
    end

    def set_file_for_remote_storage
      resource.send(:"remote_#{mount_point.to_s}_url=", original_resource_mounter.url)
    end

    def set_file_for_local_storage
      resource.send(:"#{mount_point.to_s}=", ::File.open(original_resource_mounter.file.file))
    end

    def original_resource_mounter
      original_resource.send(mount_point)
    end

  end
end