Sequel.migration do
  up do
    add_column :stats, :packets_transmitted, Integer
    add_column :stats, :packets_received, Integer
  end

  down do
    drop_column :stats, :packets_transmitted
    drop_column :stats, :packets_received
  end
end