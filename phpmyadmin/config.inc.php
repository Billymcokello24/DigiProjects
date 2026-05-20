<?php
/**
 * phpMyAdmin configuration file for DigiProjects development
 */
declare(strict_types=1);

$cfg['blowfish_secret'] = 'blowfish_secret_for_digiprojects_development_12345';

$i = 0;
$i++;

/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'cookie';

/* Server parameters */
$cfg['Servers'][$i]['host'] = '127.0.0.1';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;

/* phpMyAdmin configuration storage settings */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
