defmodule Blog.Gallery.ICloudTest do
  use ExUnit.Case, async: true

  alias Blog.Gallery.ICloud

  describe "ttl/1" do
    test "reads the seconds remaining from the signed url's e= param" do
      future = System.system_time(:second) + 3_600
      url = "https://cvws.icloud-content.com/S/abc/x.jpg?o=tok&v=1&e=#{future}&s=sig"

      ttl = ICloud.ttl(url)
      assert ttl > 3_590 and ttl <= 3_600
    end

    test "an already-expired url reports zero rather than a negative lease" do
      past = System.system_time(:second) - 500
      assert ICloud.ttl("https://x/y.jpg?e=#{past}") == 0
    end

    # A url we cannot read an expiry from is treated as stale immediately, so a
    # change in Apple's url format can only make us refresh too often — never
    # leave a dead url on screen.
    test "a url with no usable expiry is treated as already stale" do
      assert ICloud.ttl("https://x/y.jpg") == 0
      assert ICloud.ttl("https://x/y.jpg?e=soon") == 0
      assert ICloud.ttl("not a url at all") == 0
    end
  end

  describe "first_host/0" do
    test "starts at p01, which redirects to the album's real partition" do
      assert ICloud.first_host() =~ ~r/^p01-sharedstreams\.icloud\.com$/
    end
  end
end
