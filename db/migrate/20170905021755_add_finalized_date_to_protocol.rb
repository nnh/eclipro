class AddFinalizedDateToProtocol < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :finalized_date, :date
  end
end
