Sequel.migration do
  up do
    create_table(:hosts) do
      primary_key :id
      String :name, null: false
    end

    create_table(:stats) do
      primary_key :id
      foreign_key :host_id, :hosts
      DateTime :date
      BigDecimal :response, size: [15, 9]
    end
  end

  down do
    drop_table :hosts, :stats
  end
end