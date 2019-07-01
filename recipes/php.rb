[
	'php',
	'libapache2-mod-php',
].each do |pkg|
	apt_package pkg
end

systemd_unit 'apache2.service' do
	action :restart
end
