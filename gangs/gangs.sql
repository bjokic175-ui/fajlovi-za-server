-- GANGS BAZA PODATAKA - ESX LEGACY

CREATE TABLE IF NOT EXISTS `gang_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(100) NOT NULL,
  `gang` varchar(50) NOT NULL,
  `rank` varchar(50) DEFAULT 'member',
  `joined_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `gang_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_name` varchar(50) NOT NULL UNIQUE,
  `color_r` int(3) NOT NULL,
  `color_g` int(3) NOT NULL,
  `color_b` int(3) NOT NULL,
  `treasury` int(11) DEFAULT 0,
  `blip_sprite` int(11) DEFAULT 277,
  `founded_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `gang_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang` varchar(50) NOT NULL,
  `vehicle_model` varchar(50) NOT NULL,
  `plate` varchar(20),
  `spawned_by` varchar(100),
  `spawned_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`gang`) REFERENCES `gang_data`(`gang_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- INSERT GANGI U BAZU
INSERT IGNORE INTO `gang_data` (`gang_name`, `color_r`, `color_g`, `color_b`, `treasury`) VALUES
('GSF', 255, 0, 0, 0),
('Ballas', 0, 0, 255, 0),
('Bloods', 139, 0, 0, 0),
('Vagos', 255, 255, 0, 0),
('Marabunta', 0, 255, 0, 0);

-- PRIMERI CLAN LISTE
INSERT IGNORE INTO `gang_members` (`identifier`, `gang`, `rank`) VALUES
('license:abc123', 'GSF', 'leader'),
('license:def456', 'Ballas', 'leader'),
('license:ghi789', 'Bloods', 'leader'),
('license:jkl012', 'Vagos', 'leader'),
('license:mno345', 'Marabunta', 'leader');