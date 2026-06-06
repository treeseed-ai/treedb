defmodule TreeDbSdk.BlobsAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Blobs.read(client, "repo/a", %{})
    TreeDbSdk.Blobs.write(client, "ws/a", %{})
    TreeDbSdk.Blobs.download(client, "ws/a")
    TreeDbSdk.Blobs.upload(client, "ws/a", "x")
    TreeDbSdk.Blobs.create_multipart_upload(client, "ws/a", %{})
    TreeDbSdk.Blobs.upload_part(client, "ws/a", "up/a", 2, "x")
    TreeDbSdk.Blobs.complete_multipart_upload(client, "ws/a", "up/a", %{})
    TreeDbSdk.Blobs.abort_multipart_upload(client, "ws/a", "up/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :delete and
                 &1.path == "/api/v1/workspaces/ws%2Fa/blobs/uploads/up%2Fa")
           )
  end
end
