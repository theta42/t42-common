version = {
	8 => {
		'version' => '8.16.0',
		'url' => 'https://nodejs.org/dist/latest-v8.x/node-v8.16.0-linux-x64.tar.gz',
		'checksum' => 'b391450e0fead11f61f119ed26c713180cfe64b363cd945bac229130dfab64fa'
	},
	10 => {
		'version' => '10.15.3',
		'url' => 'https://nodejs.org/dist/latest-v10.x/node-v10.15.3-linux-x64.tar.gz',
		'checksum' => '6c35b85a7cd4188ab7578354277b2b2ca43eacc864a2a16b3669753ec2369d52'
	}
}

unless node['node']['working-dir'][0] == '/'
	node.override['node']['working-dir'] = "#{node['working-dir']}/#{node['node']['working-dir']}"
end

unless node['node']['version']
	node.default['node']['version'] = 8
end

unless version.key?(node['node']['version'])
	raise <<~EOH
		Unsupported NodeJS version #{node['node']['version']}.
		Supports #{version.keys}.
	EOH
end

set_version = version[node['node']['version']]

node.default['nodejs']['install_method'] = 'binary'
node.default['nodejs']['version'] = set_version['version']
node.default['nodejs']['binary']['url'] = set_version['url']
node.default['nodejs']['binary']['checksum'] = set_version['checksum']

include_recipe "nodejs"

execute 'Install NPM package.json' do
	cwd node['node']['working-dir']
	command "npm --prefix \"#{node['node']['working-dir']}\" install"
end

directory "/var/log/node/#{node['app']['name']}" do
	recursive true
end
