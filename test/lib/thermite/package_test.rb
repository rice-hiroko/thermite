require 'fileutils'
require 'tmpdir'
require 'test_helper'
require 'thermite/package'
require 'thermite/util'

module Thermite
  class PackageTest < Minitest::Test
    include Thermite::ModuleTester

    class Tester
      include Thermite::Package
      include Thermite::TestHelper
      include Thermite::Util
    end

    def test_build_package_and_unpack_tarball
      using_temp_dir do |dir, tgz_filename|
        using_project_dir(stub_dir(dir, 'project')) do |project_dir|
          extension_path = stub_extension_path(project_dir)
          stub_config(project_dir, extension_path, tgz_filename)

          mock_module.build_package
          FileUtils.rm_f(extension_path)

          # This simulates having an extension build via `install/Rakefile` instead of the
          # top-level Rakefile.
          using_install_dir(stub_dir(dir, 'install')) do
            assert_file_created(extension_path) do
              File.open(tgz_filename, 'rb') do |f|
                mock_module.unpack_tarball(f)
              end
            end
            assert_equal 'some extension', File.read(extension_path)
          end
        end
      end
    end

    private

    def described_class
      Tester
    end

    def stub_config(project_dir, extension_path, filename)
      mock_module.config.stubs(:ruby_toplevel_dir).returns(project_dir)
      mock_module.config.stubs(:ruby_extension_path).returns(extension_path)
      mock_module.config.stubs(:toml).returns(package: { version: '7.8.9' })
      mock_module.config.stubs(:tarball_filename).with('7.8.9').returns(filename)
    end

    def stub_dir(base, name)
      subdir = File.join(base, name)
      Dir.mkdir(subdir)

      subdir
    end

    def stub_extension_path(dir)
      extension_path = File.join(dir, 'lib', 'test.txt')
      Dir.mkdir(File.dirname(extension_path))
      File.write(extension_path, 'some extension')

      extension_path
    end

    def using_project_dir(project_dir)
      yield project_dir
    ensure
      FileUtils.rm_rf(project_dir)
    end

    def using_install_dir(install_dir)
      Dir.mkdir(File.join(install_dir, 'lib'))
      Dir.chdir(install_dir) do
        yield install_dir
      end
    ensure
      FileUtils.rm_rf(install_dir)
    end

    def using_temp_dir
      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'test-7.8.9.tar.gz')
        begin
          yield dir, filename
        ensure
          FileUtils.rm_f(filename)
        end
      end
    end

    def assert_file_created(filename)
      refute File.exist?(filename), "File '#{filename}' already exists."
      yield
      assert File.exist?(filename), "File '#{filename}' does not exist."
    end
  end
end
