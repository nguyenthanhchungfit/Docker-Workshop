/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.example.controllers;

import com.example.model.User;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

/**
 *
 * @author chungnt
 */
@RestController
public class UserController {

    @RequestMapping(value = "/userinfo", method = RequestMethod.GET)
    @ResponseBody
    public String getUserInfo() {
        User user = new User(1, "chungnt", "vi", "Zalo-Group");
        return user.toResponseString();
    }
}
