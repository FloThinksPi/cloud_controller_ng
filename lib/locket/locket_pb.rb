# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: locket.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'models.Resource' do
    optional :key, :string, 1
    optional :owner, :string, 2
    optional :value, :string, 3
    optional :type, :string, 4
    optional :type_code, :enum, 5, 'models.TypeCode'
  end
  add_message 'models.LockRequest' do
    optional :resource, :message, 1, 'models.Resource'
    optional :ttl_in_seconds, :int64, 2
  end
  add_message 'models.LockResponse' do
  end
  add_message 'models.ReleaseRequest' do
    optional :resource, :message, 1, 'models.Resource'
  end
  add_message 'models.ReleaseResponse' do
  end
  add_message 'models.FetchRequest' do
    optional :key, :string, 1
  end
  add_message 'models.FetchResponse' do
    optional :resource, :message, 1, 'models.Resource'
  end
  add_message 'models.FetchAllRequest' do
    optional :type, :string, 1
    optional :type_code, :enum, 2, 'models.TypeCode'
  end
  add_message 'models.FetchAllResponse' do
    repeated :resources, :message, 1, 'models.Resource'
  end
  add_enum 'models.TypeCode' do
    value :UNKNOWN, 0
    value :LOCK, 1
    value :PRESENCE, 2
  end
end

module Models
  Resource = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.Resource').msgclass
  LockRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.LockRequest').msgclass
  LockResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.LockResponse').msgclass
  ReleaseRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.ReleaseRequest').msgclass
  ReleaseResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.ReleaseResponse').msgclass
  FetchRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.FetchRequest').msgclass
  FetchResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.FetchResponse').msgclass
  FetchAllRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.FetchAllRequest').msgclass
  FetchAllResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.FetchAllResponse').msgclass
  TypeCode = Google::Protobuf::DescriptorPool.generated_pool.lookup('models.TypeCode').enummodule
end