require_relative "../config/environment.rb"
require 'pry'

class Student
    attr_accessor :name, :grade
    attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade)
      @name = name
      @grade = grade
      @id = id
  end

  def self.create_table   #don't need quotes here
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

     def self.drop_table
         sql = "DROP TABLE IF EXISTS students" #have to use quotes
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            sql = <<-SQL
            UPDATE students
            SET name = ?, grade = ? WHERE id = ?
            SQL
            DB[:conn].execute(sql, name, grade, id) #what exactly are we telling it to execute (id here)
        else
            sql = <<-SQL
            INSERT INTO students (name, grade) VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.grade)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        self
        end
    end

    def self.create (name, grade)  #why wouldn't a keyword arg work here?
        new_student = Student.new(name, grade)
        new_student.save
        new_student
    end

    def self.new_from_db(row)
        #binding.pry
        student = Student.new(row[0], row[1], row[2])
        student
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM students WHERE name = ?
        SQL
        student = DB[:conn].execute(sql, name).flatten
        #binding.pry
        new_from_db(student)
    end

    def update
        sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

end
