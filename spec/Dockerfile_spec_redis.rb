require 'docker'
require 'serverspec'
require 'redis'
require 'pry'

REDIS_PORT = 6379

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.build_from_dir('.')

    set :os, family: :redhat
    set :backend, :docker
    set :docker_image, @image.id
  end

  describe 'Dockerfile#config' do
    it 'should expose the redis port' do
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include("#{REDIS_PORT}/tcp")
    end
  end

  describe file('/etc/centos-release') do
    it { should be_file }
  end

  describe package('redis') do
    it { should be_installed }
  end

  describe 'Dockerfile#config' do
    it 'should expose the redis port' do
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include("#{REDIS_PORT}/tcp")
    end
  end

  describe 'Docker Running' do
    before(:all) do
      @container = Docker::Container.create(
        'Image'      => @image.id,
        'HostConfig' => {
          'PortBindings' => { "#{REDIS_PORT}/tcp" => [{ 'HostPort' => "#{REDIS_PORT}" }] }
        }
      )
      @container.start
    end

    describe command('redis-cli info') do
      its(:stdout) { should match /redis_version:/ }
    end

    after(:all) do
      @container.kill
      @container.delete(:force => true)
    end
  end
end
