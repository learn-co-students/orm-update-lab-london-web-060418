require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)  #optional id here
    @id = id
    @name = name
    @grade = grade
  end

  #creates students table in the database:
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  #drops the studens table from the database:
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      #grab the ID of the last inserted row,
      #the row you just inserted into the database,
      #and assign it to the be the value of the @id attribute of the given instance.
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"

    DB[:conn].execute(sql, name, grade, id).map do |row|
      self.new_from_db(row)
end
  end

  def self.new_from_db(row)   #array
    student = self.new(row[1], row[2], row[0])    # = Student.new
    # student.id = row[0]
    # student.name = row[1]
    # student.grade = row[2]
    student    #returns the newly created instance
    #array of: [[id, name, grade]]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|   #!!!
        self.new_from_db(row)
    end.first   #first element from the returned array
  end


#creates a new student object
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save     #saves student to the database
    student   #returns it
  end




end
