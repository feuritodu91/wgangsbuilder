CREATE TABLE `gangbuilder` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `society` varchar(50) NOT NULL,
  `posboss` varchar(255) NOT NULL,
  `posveh` varchar(255) NOT NULL,
  `poscoffre` varchar(255) NOT NULL,
  `posspawncar` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE `gangbuilder`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `gangbuilder`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;