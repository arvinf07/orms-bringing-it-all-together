require 'pry'


class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end  

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);"
    DB[:conn].execute(sql)
  end  

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) 
      VALUES (?,?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].last_insert_row_id
      self
    end  
  end  

  def self.create(hash_attr)
    self.new(hash_attr).save
  end  

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end  

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end  

  def self.find_or_create_by(attr_hash)
    name, breed = attr_hash[:name], attr_hash[:breed]
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    response = DB[:conn].execute(sql, name, breed)[0]
    if response.nil?
      self.create(attr_hash)
    else
      self.new_from_db(response)  
    end  
  end  

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    response = DB[:conn].execute(sql, name)[0]
    new_from_db(response)
  end  

  def update
    sql = "UPDATE dogs SET name = ?, breed = ?, id =?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end  

end
