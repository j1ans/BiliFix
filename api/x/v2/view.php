<?php
$aid = $_GET['aid'];
$appkey=$_GET['appkey'];
$build=$_GET['build'];
$device=$_GET['device'];
$from=$_GET['from'];
$mobi_app=$_GET['mobi_app'];
$platform=$_GET['platform'];
$sign=$_GET['sign'];
$ts=$_GET['ts'];

$bili_view_url = "https://app.bilibili.com/x/v2/view?actionKey=appkey&aid=".$aid."&appkey=".$appkey."&build=".$build."&device=".$device."&from=".$from."&mobi_app=".$mobi_app."&platform=".$platform."&sign=".$sign."&ts=".$ts;
$response = file_get_contents($bili_view_url);
$data = json_decode($response,true);
$cid = $data['data']['cid'];
$bvid = $data['data']['bvid'];

$host = '38.12.25.243'; // 数据库服务器地址
$db   = 'sql_bili_api_iak'; // 数据库名
$user = 'sql_bili_api_iak'; // 数据库用户名
$pass = '3ff57d6160164'; // 数据库密码

$conn = new mysqli($host, $user, $pass, $db);
$sql = "INSERT IGNORE INTO video_data (aid, cid , bvid) VALUES ('$aid', '$cid' , '$bvid')";
$conn->query($sql);
$conn->close();
header('Content-Type: application/json');
print $response;
?>

