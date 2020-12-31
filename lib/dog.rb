require 'pry'

class Dog
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    attr_accessor :id, :name, :breed

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT);
                SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if self.id
            self.update
        else
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id:row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map do |row|
            self.new_from_db(row)
        end
        dog.first
    end

    def self.find_or_create_by(name:, breed:)
        check = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if check.first
            self.new_from_db(check.flatten)
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
            self.new_from_db(row)
        end
        dog.first
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
        self
        # binding.pry
    end

end