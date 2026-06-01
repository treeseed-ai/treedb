File.rm_rf!(Application.get_env(:treedb, :data_dir))
ExUnit.start()
