defmodule Mix.Tasks.Shrty do
  defmodule Db do
    defmodule Install do
      use Mix.Task
      use Shrty.Database

      @shortdoc "Install the Shrty database"
      @moduledoc """
        A task to perform the initial setup of the Shrty Database.
      """
      def run(_) do
        # This creates the mnesia schema, this has to be done on every node before
        # starting mnesia itself, the schema gets stored on disk based on the
        # `-mnesia` config, so you don't really need to create it every time.
        IO.puts "loading up Amnesia"
        Amnesia.Schema.create

        # Once the schema has been created, you can start mnesia.
        Amnesia.start

        # When you call create/1 on the database, it creates a metadata table about
        # the database for various things, then iterates over the tables and creates
        # each one of them with the passed copying behaviour
        #
        # In this case it will keep a ram and disk copy on the current node.
        IO.puts "...creating the db"
        Database.create(disk: [node])

        # This waits for the database to be fully created.
        Database.wait

        Amnesia.transaction do
          first = %ShrtUrl{url: "https://github.com/bkono/shrty", hashid: "_"} |> ShrtUrl.write
          

          # ... initial data creation
        end

        # Stop mnesia so it can flush everything and keep the data sane.
        Amnesia.stop
        IO.puts "...all done."
      end
    end

    defmodule Uninstall do
      use Mix.Task
      use Shrty.Database

      @shortdoc "Uninstall the Shrty database"
      @moduledoc """
        A task to perform the teardown of the Shrty Database.
      """
      def run(_) do
        # Start mnesia, or we can't do much.
        Amnesia.start

        # Destroy the database.
        Database.destroy

        # Stop mnesia, so it flushes everything.
        Amnesia.stop

        # Destroy the schema for the node.
        Amnesia.Schema.destroy
      end
    end
  end
end
