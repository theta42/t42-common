
apt_repository 'Python apt repo' do
  uri 'ppa:deadsnakes/ppa'
  repo_name 'ppa-deadsnakes'
  deb_src true
  action :add
end

apt_update

[
	"python#{node['python']['version']}",
	"python#{node['python']['version']}-dev",
	"python#{node['python']['version']}-pip",

].each do |pkg|
	apt_package pkg
end

if node['python']['working-dir']
	unless node['python']['working-dir'][0] == '/'
		node.override['python']['working-dir'] = "#{node['working-dir']}/#{node['python']['working-dir']}"
	end

	execute 'Install virtual' do
		command "pip#{node['python']['version'][0]} install virtualenv"
	end

	bash 'Install python requirements file' do
		# user 'root'
		# cwd  '/mydir'
		code <<~EOH
			virtualenv #{node['python']['env_path']}
			source #{node['python']['env_path']}/bin/activate
			pip install -r #{node['python']['working-dir']}/#{node['python']['pip_requirements_path']}
		EOH
	end
end
