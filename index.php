<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Demo PHP application</title>
	<style>
		#instanceData {
			font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
			border-collapse: collapse;
			width: 100%;
		}

		#instanceData td,
		#instanceData th {
			border: 1px solid #ddd;
			padding: 8px;
		}

		#instanceData tr:nth-child(even) {
			background-color: #f2f2f2;
		}

		#instanceData tr:hover {
			background-color: #ddd;
		}

		#instanceData th {
			padding-top: 12px;
			padding-bottom: 12px;
			text-align: left;
			background-color: #4CAF50;
			color: white;
		}
	</style>
	<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen" title="default" />

</head>

<?php
$url = "http://169.254.169.254/latest/meta-data/instance-id";
$instance_id = file_get_contents($url);

$url = "http://169.254.169.254/latest/meta-data/placement/availability-zone";
$zone = file_get_contents($url);

$url = "http://169.254.169.254/latest/meta-data/ami-id";
$ami_id = file_get_contents($url);

$url = "http://169.254.169.254/latest/user-data";
$userdata = file_get_contents($url);
?>

<body>
	<center>
		<div id="content">
			<center>
				<br />
				<br />
				<h2>Instance Metadata : Version 1</h2>
				<h3>Getting the metadata details from the locally installed metadata service - http://169.254.169.254/latest</h3>
				<table border="1" width="100%" cellpadding="0" cellspacing="0" id="instanceData">
					<tr>
						<th>Metadata Path</th>
						<th>Metadata Value</th>
					</tr>
					<tr>
						<td>/meta-data/instance-id</td>
						<td><?php echo $instance_id; ?></td>
					</tr>
					<tr>
						<td>/meta-data/placement/availability-zone</td>
						<td><?php echo  $zone; ?></td>
					</tr>
					<tr>
						<td>/meta-data/ami-id</td>
						<td>
							<pre><?php echo  $ami_id; ?></pre>
						</td>
					</tr>
					<tr>
						<td>/user-data</td>
						<td>
							<pre><?php echo  $userdata; ?></pre>
						</td>
					</tr>

				</table>

			</center>
		</div>
</body>

</html>