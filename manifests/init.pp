

class celery::rabbitmq($user="some_user",
                       $vhost="some_vhost",
                       $password="CHANGEME") {

  class { 'rabbitmq::repo::apt':
    pin    => 900,
    before => Class['rabbitmq::server']
  }

  class { 'rabbitmq::server':
    delete_guest_user => true,
  }

  rabbitmq_user { "$user":
    admin    => true,
    password => $password,
    provider => 'rabbitmqctl',
  }

  rabbitmq_vhost { $vhost:
    ensure => present,
    provider => 'rabbitmqctl',
  }

  rabbitmq_user_permissions { "$user@$vhost":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    provider => 'rabbitmqctl',
  }
}


# Install the requiremnets for celery
class celery::requirements($requirements="/tmp/celery-requirements.txt",
                           $requirements_template="celery/requirements.txt") {
  file { $requirements:
    ensure => "present",
    content => template($requirements_template),
  }

  pip::install {"celery":
    requirements => $requirements,
    require => [File[$requirements],],
  }
}


class celery::server($initd_template="celery/init.d.sh",
                     $config_template="celery/celeryconfig.py",
                     $defaults_template="celery/defaults.sh",
                     $broker_user="some_user",
                     $broker_vhost="some_vhost",
                     $broker_password="CHANGEME",
                     $broker_host="localhost",
                     $broker_port="5672") {



  file { "/etc/default/celeryd":
    ensure => "present",
    content => template($defaults_template),
  }

  file { "/etc/init.d/celeryd":
    ensure => "present",
    content => template($initd_template),
    mode => "0755",
  }

  user { "celery":
    ensure => "present",
  }

  file { "/var/celery":
    ensure => "directory",
    owner => "celery",
    require => User["celery"],
  }

  file { "/var/celery/celeryconfig.py":
    ensure => "present",
    content => template($config_template),
    require => File["/var/celery"],
  }

  file { "/var/log/celery":
    ensure => "directory",
    owner => "celery",
  }

  file { "/var/run/celery":
    ensure => "directory",
    owner => "celery",
  }

  service { "celeryd":
    ensure => "running",
    require => [File["/var/celery/celeryconfig.py"],
                File["/etc/init.d/celeryd"],
                File["/var/log/celery"],
                File["/var/run/celery"] ],
  }
}


# Install the requierments for django-celery
class celery::django::requirements(
    $requirements="/tmp/celery-django-requirements.txt",
    $requirements_template="celery/django-requirements.txt") {

  file { $requirements:
    ensure => "present",
    content => template($requirements_template),
  }

  pip::install {"celery":
    requirements => $requirements,
    require => [Exec["pip::bootstrapped"], File[$requirements],],
  }
}


class celery::django($initd_template="celery/init.d.sh",
                     $config_template="celery/celeryconfig.py",
                     $defaults_template="celery/defaults.sh",
                     $broker_user="some_user",
                     $broker_vhost="some_vhost",
                     $broker_password="CHANGEME",
                     $broker_host="localhost",
                     $broker_port="5672") {

}