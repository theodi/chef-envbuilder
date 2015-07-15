module ODI
  module Envbuilder
    module Helpers
      # so it turns out I didn't remember how to recursively walk a nested hash like this :/
      def walk hash, stack = [], output = {}
        hash.each do |key, val|
          stack << key
          if val.is_a?(Hash)
            walk val, stack, output
          else
            output[stack.join(node["envbuilder"]["joiner"]).upcase] = val
            stack.pop
          end
        end
        stack.pop

        output
      end

      def dump_hash hash
        s = ''
        hash.each do |key, val|
          s << "%s: %s\n" % [
              key,
              val
          ]
        end

        s
      end

      def use_encrypted_data_bag?
        !!node["envbuilder"]["use_encrypted_data_bag"]
      end

      def bag_item(bag_name, item_name)
        if use_encrypted_data_bag?
          Chef::EncryptedDataBagItem.load(bag_name, item_name)
        else
          data_bag_item(bag_name, item_name)
        end
      end
    end
  end
end
