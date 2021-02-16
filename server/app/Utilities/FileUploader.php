<?php

namespace App\Utilities;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class FileUploader
{

    public static function upload($data)
    {

        $fileString = $data['fileString'];
        $id = $data['id'];
        $appUrl = $data['appUrl'];
        $fileName = $data['fileName'];
        $type = $data['type'];
        $tableName = $data['tableName'];
        $columnName = $data['columnName'];

        if ($type == "img") {
            $filePath = 'images/' . $fileName;
            $fileUrl = $appUrl . $filePath;
            $updateSql = array(
                $columnName => $fileUrl
            );
        } else {
            $filePath = 'files/' . $fileName;
            $fileUrl = $appUrl . $filePath;
            $updateSql = array(
                $columnName => $fileUrl
            );
        }

        Storage::disk('ftp')->put($filePath, base64_decode($fileString));
        DB::table($tableName)->where('id', $id)->update($updateSql);

        return $fileUrl;
    }
}
