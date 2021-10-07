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
        this.user_degree_year = "";

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

let user_id_e = document.getElementById('UserIDText');

let gen_id_btn_e = document.getElementById('GenUserIDButton');
gen_id_btn_e.addEventListener('click', onGenUserIDButtonClick);
function onGenUserIDButtonClick(event) {
    meta_info.generate_user_id();
    user_id_e.value = meta_info.user_id;
}

let copy_id_btn_e = document.getElementById('CopyUserIDButton');
copy_id_btn_e.addEventListener('click', onCopyUserIDButtonClick);
function onCopyUserIDButtonClick(event) {
    copy_to_clipboard(meta_info.user_id);
}

let user_gender_e = document.getElementById('UserGenderSelect');
user_gender_e.addEventListener('change', onUserGenderSelectChange);
function onUserGenderSelectChange(event) {
    meta_info.user_gender = user_gender_e.options[user_gender_e.selectedIndex].text;
}

let user_age_e = document.getElementById('UserAgeText');
user_age_e.addEventListener('change', onUserAgeTextChange);
function onUserAgeTextChange(event) {
    meta_info.user_age = user_age_e.value;
}

let user_major_e = document.getElementById('UserMajorText');
user_major_e.addEventListener('change', onUserMajorTextChange);
function onUserMajorTextChange(event) {
    meta_info.user_major = user_major_e.value;
}

let user_degree_e = document.getElementById('UserDegreeText');
user_degree_e.addEventListener('change', onUserDegreeTextChange);
function onUserDegreeTextChange(event) {
    meta_info.user_degree = user_degree_e.value;
}

let user_degree_year_e = document.getElementById('UserDegreeYearText');
user_degree_year_e.addEventListener('change', onUserDegreeYearTextChange);
function onUserDegreeYearTextChange(event) {
    meta_info.user_degree_year = user_degree_year_e.value;
}

let save_user_btn_e = document.getElementById('SaveUserButton');
save_user_btn_e.addEventListener('click', onSaveUserButtonClick);
function onSaveUserButtonClick(event) {
    write_user();
    copy_to_clipboard(meta_info.user_id);
    setTimeout(function() { window.close() }, 500); // close window automatically
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
        user_degree_year: meta_info.user_degree_year,
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
user_gender_e.value = meta_info.user_gender;
user_age_e.value = meta_info.user_age;
user_major_e.value = meta_info.user_major;
user_degree_e.value = meta_info.user_degree;
user_degree_year_e.value = meta_info.user_degree_year;
