/**
 * MonitorController.java
 * <p>
 * Copyright 2023 smartloli
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kafka.eagle.web.controller;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.kafka.eagle.common.constants.KConstants;
import org.kafka.eagle.common.utils.CalendarUtil;
import org.kafka.eagle.common.utils.Md5Util;
import org.kafka.eagle.pojo.cluster.ClusterInfo;
import org.kafka.eagle.pojo.topic.TopicSummaryInfo;
import org.kafka.eagle.web.service.IClusterDaoService;
import org.kafka.eagle.web.service.ITopicSummaryDaoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Performance indicators and message order used to monitor the system.
 *
 * @Author: smartloli
 * @Date: 2023/7/3 22:43
 * @Version: 3.4.0
 */
@Controller
@RequestMapping("/monitor")
@Slf4j
public class MonitorController {

    @Autowired
    private IClusterDaoService clusterDaoService;

    @Autowired
    private ITopicSummaryDaoService topicSummaryDaoService;

    @GetMapping("/produce")
    public String produceView() {
        return "monitor/produce.html";
    }

    /**
     * Get producer chart data by ajax.
     */
    @RequestMapping(value = "/produce/msg/chart/ajax", method = RequestMethod.GET)
    public void getMonitorProduceMsgChartAjax(HttpServletResponse response, HttpServletRequest request, HttpSession session) {
        try {
            String remoteAddr = request.getRemoteAddr();
            String clusterAlias = Md5Util.generateMD5(KConstants.SessionClusterId.CLUSTER_ID + remoteAddr);
            log.info("Monitor produce chart :: get remote[{}] clusterAlias from session md5 = {}", remoteAddr, clusterAlias);
            Long cid = Long.parseLong(session.getAttribute(clusterAlias).toString());
            ClusterInfo clusterInfo = clusterDaoService.clusters(cid);

            Map<String, Object> param = new HashMap<>();
            param.put("cid", clusterInfo.getClusterId());
            param.put("topic", request.getParameter("topic"));
            param.put("stime", request.getParameter("stime"));
            param.put("etime", request.getParameter("etime"));

            // topic summary
            List<TopicSummaryInfo> topicSummaryInfos = topicSummaryDaoService.pagesOfDay(param);

            Map<String, Long> logSizeOfDayMaps = new HashMap<>();
            for(TopicSummaryInfo topicSummaryInfo: topicSummaryInfos){
                logSizeOfDayMaps.put(topicSummaryInfo.getDay(), topicSummaryInfo.getLogSizeDiffVal());
            }

            int index = 0;
            try {
                index = CalendarUtil.getDiffDay(param.get("stime").toString(), param.get("etime").toString());
            } catch (Exception e) {
                log.error("Get monitor produce msg chart diff day has error, msg is {}", e);
            }

            JSONArray arrays = new JSONArray();

            for (int i = index; i >= 0; i--) {
                String day = CalendarUtil.getCustomLastDay(i);
                if (logSizeOfDayMaps.containsKey(day)) {
                    JSONObject object = new JSONObject();
                    object.put("x", CalendarUtil.getCustomLastDay("yyyy-MM-dd", i));
                    object.put("y", logSizeOfDayMaps.get(day).toString());
                    arrays.add(object);
                } else {
                    JSONObject object = new JSONObject();
                    object.put("x", CalendarUtil.getCustomLastDay("yyyy-MM-dd", i));
                    object.put("y", 0);
                    arrays.add(object);
                }
            }

            String target = arrays.toJSONString();
            if (StrUtil.isBlank(target)) {
                target = "";
            }
            byte[] output = target.getBytes();
            BaseController.response(output, response);
        } catch (Exception e) {
            log.error("Get monitor produce topic msg chart has error, msg is {}", e);
        }
    }

}
