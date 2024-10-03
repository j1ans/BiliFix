<?php
header('Content-Type: application/json');
$cid = $_GET['cid'];
$wbi_playurl = "https://api.bilibili.com/x/player/wbi/playurl?";
$nav_wbi_sign_url = "https://api.bilibili.com/x/web-interface/nav";
$nav_response = file_get_contents($nav_wbi_sign_url);
$wbi_data = json_decode($nav_response,true);
$raw_img_key = $wbi_data['data']['wbi_img']['img_url'];
$raw_sub_key = $wbi_data['data']['wbi_img']['sub_url'];
$fake_link_replace = "https://i0.hdslb.com/bfs/wbi/";
$remove_array = array($fake_link_replace,".png");
$img_key = str_replace($remove_array,"",$raw_img_key);
$sub_key = str_replace($remove_array,"",$raw_sub_key);
$raw_wbi_key = $img_key.$sub_key;

$mixinKeyEncTab = [
    46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49,
    33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40,
    61, 26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11,
    36, 20, 34, 44, 52
];

function getMixinKey($orig) {
    global $mixinKeyEncTab;
    $result = '';
    foreach ($mixinKeyEncTab as $i) {
        $result .= $orig[$i];
    }
    return substr($result, 0, 32);
}
$result_wbi_key = getMixinKey($raw_wbi_key);
$wts = time();

$host = '38.12.25.243'; // 数据库服务器地址
$db   = 'sql_bili_api_iak'; // 数据库名
$user = 'sql_bili_api_iak'; // 数据库用户名
$pass = '3ff57d6160164'; // 数据库密码

$conn = new mysqli($host, $user, $pass, $db);

$sql = $conn->prepare("SELECT bvid FROM video_data WHERE cid = ".$cid." LIMIT 1");
$sql->execute();
$result = $sql->get_result();
$row = $result->fetch_assoc();
// 视频api 需要 bvid cid
$md5_query = "bvid=".$row['bvid']."&cid=".$cid."&platform=html5"."&wts=".$wts.$result_wbi_key;
$w_rid = md5($md5_query);
$url_query = "bvid=".$row['bvid']."&cid=".$cid."&platform=html5"."&wts=".$wts."&w_rid=".$w_rid;
$final_wbi_playurl =$wbi_playurl.$url_query;
$options = [
    'http' => [
        'method' => 'GET',
        'header' => "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3\r\n" .
                    "Referer: https://www.bilibili.com/\r\n"
    ]
];
$context = stream_context_create($options);
$video_response = file_get_contents($final_wbi_playurl, false, $context);
$video_json_data = json_decode($video_response,true);

$video_encode_data = [
    "format" => $video_json_data['data']['format'],
    "timelength" => $video_json_data['data']['timelength'],
    "accept_format" => $video_json_data['data']['accept_format'],
    "accept_quality" => [2, 1],
    "durl" => [
        [
            "length" => $video_json_data['data']['durl'][0]['length'],
            "size" => $video_json_data['data']['durl'][0]['size'],
            "url" => $video_json_data['data']['durl'][0]['url'],
            "backup_url" => [
                $video_json_data['data']['durl'][0]['url'],             
				$video_json_data['data']['durl'][0]['url']
				]
        ]
    ]
];
$json_final = json_encode($video_encode_data, JSON_PRETTY_PRINT);
print $json_final;

?>