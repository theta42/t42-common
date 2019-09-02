version_map = {
	8 => {
		'version' => '8.16.1',
		'url' => 'https://nodejs.org/dist/v8.16.1/node-v8.16.1-linux-x64.tar.gz',
		'checksum' => 'a7f60fc6f41bedd2a387bc99067df11d53161fa235b8c90c6b5e73b0dff9af8e'
	},
	10 => {
		'version' => '10.16.3',
		'url' => 'https://nodejs.org/dist/v10.16.3/node-v10.16.3-linux-x64.tar.gz',
		'checksum' => '2f0397bb81c1d0c9901b9aff82a933257bf60f3992227b86107111a75b9030d9'
	},
	12 => {
		'version' => '12.9.1',
		'url' => 'https://nodejs.org/dist/v12.9.1/node-v12.9.1-linux-x64.tar.gz',
		'checksum' => '5488e9d9e860eb344726aabdc8f90d09e36602da38da3d16a7ee852fd9fbd91f'
	}
}

unless node['nodejs']['working-dir'][0] == '/'
	node.override['nodejs']['working-dir'] = "#{node['working-dir']}/#{node['nodejs']['working-dir']}"
end

unless version.key?(node['nodejs']['install_version'])
	raise <<~EOH
		Unsupported NodeJS version #{node['nodejs']['install_version']}.
		Supports #{version.keys}.
	EOH
end

set_version = version_map[node['nodejs']['install_version']]

node.default['nodejs']['install_method'] = 'binary'
node.default['nodejs']['version'] = set_version['version'].to_str
node.default['nodejs']['binary']['url'] = set_version['url']
node.default['nodejs']['binary']['checksum'] = set_version['checksum']

node.default['nodejs']['env_path'] = "/opt/theta42/#{node['app']['name']}/env/node"

include_recipe "nodejs"

directory node['nodejs']['env_path'] do
	recursive true
end

file "#{node['nodejs']['env_path']}/package.json" do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open("#{node['nodejs']['working-dir']}/package.json").read
  action :create
end

execute 'Install NPM package.json' do
	cwd node['nodejs']['env_path']
	command "npm --prefix #{node['nodejs']['env_path']} install #{node['nodejs']['env_path']}"
end

directory "/var/log/node/#{node['app']['name']}" do
	recursive true
end
