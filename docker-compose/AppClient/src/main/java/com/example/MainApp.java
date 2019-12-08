package com.example;

import com.example.controllers.UserClient;
import java.io.IOException;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestClientException;

@SpringBootApplication
public class MainApp {

    public static void main(String[] args) throws RestClientException, IOException {
        ApplicationContext ctx = SpringApplication.run(MainApp.class, args);
        UserClient userClient =ctx.getBean(UserClient.class);
		System.out.println(userClient);
		userClient.getUserInfo();
    }

    @Bean
    public UserClient userClient() {
        return new UserClient();
    }
}
