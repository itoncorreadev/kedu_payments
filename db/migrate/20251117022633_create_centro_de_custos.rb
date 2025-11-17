class CreateCentroDeCustos < ActiveRecord::Migration[8.1]
  def change
    create_table :centro_de_custos do |t|
      t.string :nome, null: false

      t.timestamps
    end
    add_index :centro_de_custos, :nome, unique: true
  end
end
