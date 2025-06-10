package com.wf.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.AboutListVO;
import com.wf.entity.DoneListVO;
import com.wf.entity.SubmitListVO;
import com.wf.entity.TodoListVO;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Map;

/**
 * @author chonghui. tian
 *         date 2025/4/18 11:47
 *         description
 */
@Mapper
public interface TaskMapper {

        @Select("<script>" +
                        "SELECT COUNT(1) FROM flw_task_actor " +
                        "WHERE actor_id = #{userId} AND actor_type = 0 " +
                        "<if test='tenantId != null'> AND tenant_id = #{tenantId} </if>" +
                        "</script>")
        Long todoCount(@Param("userId") String userId, @Param("tenantId") String tenantId);

        @Select("<script>" +
                        "SELECT COUNT(1) FROM flw_his_task_actor " +
                        "WHERE actor_id = #{userId} AND actor_type = 0 " +
                        "<if test='tenantId != null'> AND tenant_id = #{tenantId} </if>" +
                        "</script>")
        Long doneCount(@Param("userId") String userId, @Param("tenantId") String tenantId);

        @Select("<script>" +
                        "SELECT COUNT(1) FROM flw_his_instance " +
                        "WHERE create_id = #{userId} " +
                        "<if test='tenantId != null'> AND tenant_id = #{tenantId} </if>" +
                        "</script>")
        Long submitCount(@Param("userId") String userId, @Param("tenantId") String tenantId);

        @Select("<script>" +
                        "SELECT COUNT(1) FROM flw_his_task_actor " +
                        "WHERE actor_id = #{userId} AND actor_type = 0 AND weight = 6 " +
                        "<if test='tenantId != null'> AND tenant_id = #{tenantId} </if>" +
                        "</script>")
        Long aboutCount(@Param("userId") String userId, @Param("tenantId") String tenantId);

        /**
         * SELECT
         * 	hi.id AS instanceId,
         * 	CONCAT(
         * 		COALESCE ( hi.create_by, '系统' ),
         * 		'发起的',
         * 	COALESCE ( ei.process_name, '未知流程' )) AS title,
         * 	ei.process_name,
         * 	hi.create_by AS startName,
         * 	hi.create_time AS submitTime,
         * 	hi.current_node_name AS currentNode,
         * 	hi.instance_state AS taskState,
         * 	t.create_time AS arriveTime
         * FROM
         * 	flw_task_actor ta
         * 	LEFT JOIN flw_task t ON t.id = ta.task_id
         * 	LEFT JOIN flw_his_instance hi ON hi.id = ta.instance_id
         * 	LEFT JOIN flw_ext_instance ei ON ei.id = hi.id
         * WHERE
         * 	ta.actor_id = '20240815'
         * 	AND ta.actor_type = 0
         * ORDER BY
         * 	ta.id DESC
         * 	LIMIT 10
         */
        @Select("<script>" +
                "SELECT " +
                "    hi.id AS instanceId, " +
                "    CONCAT(COALESCE(hi.create_by, '系统'), '发起的', COALESCE(ei.process_name, '未知流程')) AS title, " +
                "    ei.process_name, " +
                "    hi.create_by AS startName, " +
                "    hi.create_time AS submitTime, " +
                "    hi.current_node_name AS currentNode, " +
                "    hi.instance_state AS taskState, " +
                "    t.create_time AS arriveTime " +
                "FROM flw_task_actor ta " +
                "LEFT JOIN flw_task t ON t.id = ta.task_id " +
                "LEFT JOIN flw_his_instance hi ON hi.id = ta.instance_id " +
                "LEFT JOIN flw_ext_instance ei ON ei.id = hi.id " +
                "WHERE ta.actor_id = #{userId} " +
                "  AND ta.actor_type = 0 " +
                "  <if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if> " +
                "ORDER BY ta.id DESC " +
                "</script>")
        IPage<TodoListVO> todoList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

        /**
         * SELECT
         * 	hi.id AS instanceId,
         * 	CONCAT(
         * 		COALESCE ( hi.create_by, '系统' ),
         * 		'发起的',
         * 	COALESCE ( ei.process_name, '未知流程' )) AS title,
         * 	ei.process_name,
         * 	hi.create_by AS startName,
         * 	ht.task_name AS currentNode,
         * 	ht.task_state,
         * 	ht.create_time AS arriveTime,
         * 	ht.finish_time
         * FROM
         * 	flw_his_task_actor hta
         * 	LEFT JOIN flw_his_task ht ON ht.id = hta.task_id
         * 	LEFT JOIN flw_his_instance hi ON hi.id = hta.instance_id
         * 	LEFT JOIN flw_ext_instance ei ON ei.id = hi.id
         * WHERE
         * 	hta.actor_id = '20240815'
         * 	AND hta.actor_type = 0
         * 	-- AND ht.task_type NOT IN (-1, 2, 25)
         * ORDER BY
         * 	hta.id DESC
         * 	LIMIT 10
         */
        @Select("<script>" +
                "SELECT " +
                "    hi.id AS instanceId, " +
                "    CONCAT(COALESCE(hi.create_by, '系统'), '发起的', COALESCE(ei.process_name, '未知流程')) AS title, " +
                "    ei.process_name, " +
                "    hi.create_by AS startName, " +
                "    ht.task_name AS currentNode, " +
                "    ht.task_state, " +
                "    ht.create_time AS arriveTime, " +
                "    ht.finish_time " +
                "FROM flw_his_task_actor hta " +
                "LEFT JOIN flw_his_task ht ON ht.id = hta.task_id " +
                "LEFT JOIN flw_his_instance hi ON hi.id = hta.instance_id " +
                "LEFT JOIN flw_ext_instance ei ON ei.id = hi.id " +
                "WHERE hta.actor_id = #{userId} " +
                "  AND hta.actor_type = 0 " +
                //"  AND (hta.weight != 6 OR hta.weight IS NULL) " +
                "  <if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if> " +
                "ORDER BY hta.id DESC " +
                "</script>")
        IPage<DoneListVO> doneList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

        /**
         * SELECT
         * 	hi.id AS instanceId,
         * 	CONCAT( COALESCE ( hi.create_by, '系统' ), '发起的', COALESCE ( ei.process_name, '未知流程' ) ) AS title,
         * 	ei.process_name,
         * 	hi.create_by AS startName,
         * 	hi.current_node_name AS currentNode,
         * 	hi.instance_state AS taskState,
         * 	hi.create_time AS submitTime,
         * 	hi.end_time
         * FROM
         * 	flw_his_instance hi
         * 	LEFT JOIN flw_ext_instance ei ON ei.id = hi.id
         * WHERE
         * 	hi.create_id = '20240815'
         * 	and ei.process_type = 'flow_user'
         * 	and hi.instance_state = 1
         * ORDER BY
         * 	hi.id DESC
         * 	LIMIT 10
         */
        @Select("<script>" +
                "SELECT " +
                "    hi.id AS instanceId, " +
                "    CONCAT( COALESCE( hi.create_by, '系统' ), '发起的', COALESCE( ei.process_name, '未知流程' ) ) AS title, " +
                "    ei.process_name, " +
                "    hi.create_by AS startName, " +
                "    hi.current_node_name AS currentNode, " +
                "    hi.instance_state AS taskState, " +
                "    hi.create_time AS submitTime, " +
                "    hi.end_time " +
                "FROM flw_his_instance hi " +
                "LEFT JOIN flw_ext_instance ei ON hi.id = ei.id " +
                "<where> " +
                "    <if test='userId != null'> " +
                "        hi.create_id = #{userId} " +
                "    </if> " +
                "    <if test='tenantId != null'> " +
                "        AND hi.tenant_id = #{tenantId} " +
                "    </if> " +
                "</where> " +
                "ORDER BY hi.id DESC " +
                "</script>")
        IPage<SubmitListVO> submitList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page<SubmitListVO> page);

        /**
         * select
         *     hi.id AS instanceId,
         *     CONCAT(COALESCE(hi.create_by, '系统'), '发起的', COALESCE(ei.process_name, '未知流程')) AS title,
         *     ei.process_name,
         *     hi.create_by AS startName,
         *     hi.current_node_name AS currentNode,
         *     hi.instance_state AS taskState,
         *     hi.create_time AS submitTime,
         *     hi.end_time
         * from flw_his_task_actor hta
         * LEFT JOIN flw_his_instance hi ON hi.id = hta.instance_id
         * LEFT JOIN flw_ext_instance ei ON ei.id = hi.id
         * where
         * hta.actor_id = '20240815' and hta.actor_type = 0 and hta.weight = 6
         * ORDER BY hta.id desc
         * limit 10
         */
        @Select("<script>" +
                "SELECT " +
                "    hi.id AS instanceId, " +
                "    CONCAT(COALESCE(hi.create_by, '系统'), '发起的', COALESCE(ei.process_name, '未知流程')) AS title, " +
                "    ei.process_name, " +
                "    hi.create_by AS startName, " +
                "    hi.current_node_name AS currentNode, " +
                "    hi.instance_state AS taskState, " +
                "    hi.create_time AS submitTime, " +
                "    hi.end_time " +
                "FROM flw_his_task_actor hta " +
                "LEFT JOIN flw_his_instance hi ON hi.id = hta.instance_id " +
                "LEFT JOIN flw_ext_instance ei ON ei.id = hi.id " +
                "WHERE hta.actor_id = #{userId} " +
                "AND hta.actor_type = 0 " +
                "AND hta.weight = 6 " +
                "<if test='tenantId != null'> " +
                "    AND hi.tenant_id = #{tenantId} " +
                "</if> " +
                "ORDER BY hta.id DESC " +
                "</script>")
        IPage<AboutListVO> aboutList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

        @Select("<script>" +
                "SELECT i.business_key " +
                "FROM flw_instance i " +
                "INNER JOIN flw_task_actor ta ON i.id = ta.instance_id " +
                "WHERE ta.actor_id = #{userId} " +
                "<if test='tenantId != null'> AND i.tenant_id = #{tenantId} </if> " +
                "LIMIT #{current}, #{size} " +
                "</script>")
        List<Long> getBusinessKeys(@Param("userId") Long userId, @Param("tenantId") Long tenantId, @Param("current") long current, @Param("size") long size);
}
