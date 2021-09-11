"use strict";

////////////////////////////////////////////////////////////////////////
//                               Class                                //
////////////////////////////////////////////////////////////////////////

class MetaInfo {
    constructor() {
        this.user_id = "";
        this.user_gender = "";
        this.user_age = "";
        this.user_major = "";
        this.user_degree = "";

        this.generate_user_id();
    }

    generate_user_id() {
        let new_id = Math.floor(Math.random() * 1e6); // make user id a six-digit number
        this.user_id = new_id.toString().padStart(6, "0");
    }
}

////////////////////////////////////////////////////////////////////////
//                            DOM Handles                             //
////////////////////////////////////////////////////////////////////////

let user_id_e       = document.getElementById('UserIDText');
let gen_id_btn_e    = document.getElementById('GenUserIDButton');
let copy_id_btn_e   = document.getElementById('CopyUserIDButton');
let user_gender_e   = document.getElementById('UserGenderSelect');
let user_age_e      = document.getElementById('UserAgeText');
let user_major_e    = document.getElementById('UserMajorText');
let user_degree_e   = document.getElementById('UserDegreeText');
let save_user_btn_e = document.getElementById('SaveUserButton');

////////////////////////////////////////////////////////////////////////
//                             Callbacks                              //
////////////////////////////////////////////////////////////////////////

function onUserIDTextChange(event) {
    var select = event.target;
    meta_info.user_id = select.value;
}

function onGenUserIDButtonClick(event) {
    meta_info.generate_user_id();
    user_id_e.value = meta_info.user_id;
}

function onCopyUserIDButtonClick(event) {
    copy_to_clipboard(meta_info.user_id);
}

function onUserGenderSelectChange(event) {
    var select = event.target;
    meta_info.user_gender = select.options[select.selectedIndex].text;
}

function onUserAgeTextChange(event) {
    var select = event.target;
    meta_info.user_age = select.value;
}

function onUserMajorTextChange(event) {
    var select = event.target;
    meta_info.user_major = select.value;
}

function onUserDegreeTextChange(event) {
    var select = event.target;
    meta_info.user_degree = select.value;
}

function onSaveUserButtonClick(event) {
    write_user();
    copy_to_clipboard(meta_info.user_id);
}

////////////////////////////////////////////////////////////////////////
//                            Subfunctions                            //
////////////////////////////////////////////////////////////////////////

function twodigit_str(n) {
    return n > 9 ? "" + n : "0" + n;
}

function write_user() {
    let date = new Date();
    let timestamp = date.getFullYear().toString() + "-" +
                    twodigit_str((date.getMonth()+1)) + "-" +
                    twodigit_str(date.getDate()) + " " +
                    twodigit_str(date.getHours()) + ":" +
                    twodigit_str(date.getMinutes()) + ":" +
                    twodigit_str(date.getSeconds());

    let json_dict = {
        user_id: meta_info.user_id,
        user_gender: meta_info.user_gender,
        user_age: meta_info.user_age,
        user_major: meta_info.user_major,
        user_degree: meta_info.user_degree,
        datetime: timestamp,
    };

    let json_str = JSON.stringify(json_dict, function(k,v) { if(v instanceof Array) return JSON.stringify(v); return v; }, 2)
                   .replace(/\\/g, '')
                   .replace(/\"\[/g, '[')
                   .replace(/\]\"/g,']')
                   .replace(/\"\{/g, '{')
                   .replace(/\}\"/g,'}');

    let anchor = document.createElement('a');
    anchor.href = "data:application/octet-stream,"+encodeURIComponent(json_str);
    anchor.download = "User_" + meta_info.user_id.toString() + '.txt';
    anchor.click();
}

function copy_to_clipboard(text) {
    var dummy = document.createElement("textarea");
    document.body.appendChild(dummy);
    dummy.value = text;
    dummy.select();
    document.execCommand("copy");
    document.body.removeChild(dummy);
}

////////////////////////////////////////////////////////////////////////
//                           Main Function                            //
////////////////////////////////////////////////////////////////////////

var meta_info = new MetaInfo();
user_id_e.value = meta_info.user_id;
user_id_e.addEventListener('change', onUserIDTextChange);
gen_id_btn_e.addEventListener('click', onGenUserIDButtonClick)
copy_id_btn_e.addEventListener('click', onCopyUserIDButtonClick)
user_gender_e.value = meta_info.user_gender;
user_gender_e.addEventListener('change', onUserGenderSelectChange);
user_age_e.value = meta_info.user_age;
user_age_e.addEventListener('change', onUserAgeTextChange);
user_major_e.value = meta_info.user_major;
user_major_e.addEventListener('change', onUserMajorTextChange);
user_degree_e.value = meta_info.user_degree;
user_degree_e.addEventListener('change', onUserDegreeTextChange);
save_user_btn_e.addEventListener('click', onSaveUserButtonClick)
