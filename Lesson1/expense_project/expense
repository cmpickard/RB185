#! /usr/bin/env ruby

require "pg"
require 'date'
require 'io/console'

class ExpenseData
  def initialize
    @connection = PG.connect(dbname: "rb185")
    setup_schema
  end

  def setup_schema
    result = @connection.exec("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'expenses';")
    if result.values.flatten[0] == '0'
      sql = <<~table_creation
        CREATE TABLE expenses(
        id serial PRIMARY KEY,
        amount decimal(6,2) NOT NULL CHECK (amount > 0.0),
        memo text NOT NULL,
        created_on date NOT NULL
      );
    table_creation
    @connection.exec(sql)
    end
  end

  def list_expenses
    result = @connection.exec("SELECT * FROM expenses ORDER BY created_on ASC")
    display_expenses(result)
  end

  def display_count(result)
    count = result.values.size
    case count
    when 0
      puts "There are no expenses."
    when 1
      puts "There is 1 expense."
    else
      puts "There are #{count} expenses."
    end
  end

  def display_total(value)
    puts "--------------------------------------------------"
    puts "Total" + "#{value}".rjust(26)
  end

  def display_expenses(result)
    display_count(result)
    result.each do |tuple|
      columns = [ tuple["id"].rjust(3),
                  tuple["created_on"].rjust(10),
                  tuple["amount"].rjust(12),
                  tuple["memo"] ]

      puts columns.join(" | ")
    end
    sum = result.field_values("amount").map(&:to_f).inject(:+)
    display_total(sum) unless result.values.size == 0
  end

  def add_expense(amount, memo)
    date = Date.today
    sql = "INSERT INTO expenses (amount, memo, created_on) VALUES ($1, $2, $3)"
    @connection.exec_params(sql, [amount, memo, date])
  end

  def search_expenses(search_term)
    sql = "SELECT * FROM expenses WHERE memo ILIKE $1;"
    result = @connection.exec_params(sql, [search_term])
    display_expenses(result)
  end

  def delete_expense(idx)
    ids = @connection.exec("SELECT id FROM expenses;").values.flatten
    abort "There is no expense with the id '#{ids}'." unless ids.include?(idx)
    
    select_sql = "SELECT * FROM expenses WHERE id = $1"
    expense = @connection.exec_params(select_sql, [idx])
    delete_sql = "DELETE FROM expenses WHERE id = $1"
    @connection.exec_params(delete_sql, [idx])

    puts "The following expense has been deleted: "
    display_expenses(expense)
  end

  def delete_all_expenses
    @connection.exec("DELETE FROM expenses;")
    puts "All expenses have been cleared."
  end
end

class CLI
  def initialize
    @application = ExpenseData.new
  end

  def run(arguments)
    command = arguments.shift
    case command
    when "add"
      amount = arguments[0]
      memo = arguments[1]
      abort "You must provide an amount and memo." unless amount && memo
      @application.add_expense(amount, memo)
    when "list"
      @application.list_expenses
    when "search"
      search_term = '%' + arguments[0] + '%'
      @application.search_expenses(search_term)
    when "delete"
      delete_idx = arguments[0]
      @application.delete_expense(delete_idx)
    when "clear"
      loop do
        puts "Are you sure you wish to delete all expenses? (y/n)"
        ans = $stdin.getch
        @application.delete_all_expenses if ans == 'y'
        break if ans == 'n' || ans == 'y'
        puts "You must select 'y' or 'n'."
      end
    else
      display_help
    end
  end

  def display_help
    puts <<~HELP
      An expense recording system

      Commands:

      add AMOUNT MEMO - record a new expense
      clear - delete all expenses
      list - list all expenses
      delete NUMBER - remove expense with id NUMBER
      search QUERY - list expenses with a matching memo field
    HELP
  end
end

CLI.new.run(ARGV)