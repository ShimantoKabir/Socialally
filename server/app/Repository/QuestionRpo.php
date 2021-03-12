<?php

namespace App\Repository;

use Exception;
use App\Models\Question;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuestionRpo
{

    public function read(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $res["code"] = 200;
            $res['msg'] = "OK";
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function create(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rQuestion = $request->question;
        DB::beginTransaction();
        try {

            $question = new Question();
            $question->question = $rQuestion['question'];
            $question->save();

            $res["code"] = 200;
            $res['msg'] = "Question save successfully!";
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function update(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rQuestion = $request->question;
        DB::beginTransaction();
        try {

            Question::where("id", $rQuestion['id'])->update([
                "question" => $rQuestion['question']
            ]);

            $res["code"] = 200;
            $res['msg'] = "Question updated successfully!";
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }


    public function delete(Request $request, $id)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        DB::beginTransaction();
        try {

            Question::where("id", $id)->delete();

            $res["code"] = 200;
            $res['msg'] = "Question deleted successfully!";
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function readByQuery(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            if (!$request->has('par-page')) {
                $res['code'] = 404;
                $res['msg'] = "Par page required!";
            } else if (!$request->has('page-index')) {
                $res['code'] = 404;
                $res['msg'] = "Page index required!";
            } else {

                $parPage = $request->query('par-page');
                $pageIndex = $request->query('page-index');

                $sql = "SELECT 
                            *
                        FROM 
                            Questions
                        ORDER BY 
                            id DESC 
                        LIMIT 
                            " . $pageIndex . ", " . $parPage;

                $res['questions'] = DB::select(DB::raw($sql));
                $res['msg'] = "Questions fetched successfully!";
                $res['code'] = 200;
            }
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }
}
