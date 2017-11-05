require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerApkanalyzer do
    it "should be a plugin" do
      expect(Danger::DangerApkanalyzer.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @apkanalyzer = @dangerfile.apkanalyzer
        @apkanalyzer.apk_file = "app.apk"
      end

      it "file_size" do
        process_mock = double("Process::Status")
        allow(process_mock).to receive(:success?).and_return true
        allow(Open3).to receive(:capture3).and_return ["10M", "", process_mock]

        @apkanalyzer.file_size

        output = @apkanalyzer.status_report[:markdowns].first
        expect(output.message).to include("10M")
      end

      it "permissions" do
        process_mock = double("Process::Status")
        allow(process_mock).to receive(:success?).and_return true
        allow(Open3).to receive(:capture3).and_return ["android.permission.INTERNET\nandroid.permission.ACCESS_NETWORK_STATE", "", process_mock]

        @apkanalyzer.permissions

        output = @apkanalyzer.status_report[:markdowns].first
        expect(output.message).to include("android.permission.INTERNET")
        expect(output.message).to include("android.permission.ACCESS_NETWORK_STAT")
      end

      it "method_references" do
        process_mock = double("Process::Status")
        allow(process_mock).to receive(:success?).and_return true
        allow(Open3).to receive(:capture3).and_return ["classes2.dex    1234\nclasses.dex     5678", "", process_mock]

        @apkanalyzer.method_references

        output = @apkanalyzer.status_report[:markdowns].first
        expect(output.message).to include("classes2.dex")
        expect(output.message).to include("1234")
        expect(output.message).to include("classes.dex")
        expect(output.message).to include("5678")
      end
    end
  end
end
