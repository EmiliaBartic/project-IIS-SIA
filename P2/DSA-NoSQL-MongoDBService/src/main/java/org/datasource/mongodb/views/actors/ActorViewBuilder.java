package org.datasource.mongodb.views.actors;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.datasource.mongodb.MongoDataSourceConnector;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ActorViewBuilder {


    private List<ActorView> actorsViewList = new ArrayList<>();
    private MongoDataSourceConnector dataSourceConnector;

    public ActorViewBuilder(MongoDataSourceConnector dataSourceConnector) {
        this.dataSourceConnector = dataSourceConnector;
    }

    public List<ActorView> getActorsViewList() {
        return actorsViewList;
    }

    public ActorViewBuilder build() throws Exception {
        return this.select();
    }

    public ActorViewBuilder select() throws Exception {
        MongoDatabase db = dataSourceConnector.getMongoDatabase();

        // Conectare la colectia actors si mapare automata pe clasa ActorView
        MongoCollection<ActorView> actorsCollection = db.getCollection("actors", ActorView.class);

        // Extragem toate documentele si le punem in lista noastra
        actorsCollection.find().into(this.actorsViewList);

        return this;
    }
}